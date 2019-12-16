namespace:
	kubectl create namespace k8s-demo || true

deploy_server:
	kubectl -n k8s-demo apply -f service-test.dpl.yml

pod_ips:
	kubectl -n k8s-demo get pods --selector=app=service_test_pod -o jsonpath='{.items[*].status.podIP}'

client:
	# adjust the IP with the IP of the target pod
	kubectl -n k8s-demo apply -f service-client-test.pod.yml

client_logs:
	kubectl -n k8s-demo logs service-test-client1

deploy_server_service:
	kubectl -n k8s-demo apply -f service-test.svc.yml

client2:
	kubectl -n k8s-demo apply -f service-client2-test.pod.yml

client2_logs:
	kubectl -n k8s-demo logs service-test-client2

deploy_server_service_nodeport:
	kubectl -n k8s-demo apply -f service-test-nodeport.svc.yml

deploy_server_service_loadbalancer:
	kubectl -n k8s-demo apply -f service-test-loadbalancer.svc.yml

helm_install_metrics_server:
	helm install -n kube-system -f metrics-server.values.yaml metrics-server stable/metrics-server

get_metrics:
	kubectl get --raw "/apis/metrics.k8s.io/v1beta1/pods" | jq

create_hpa:
	kubectl -n k8s-demo autoscale deployment service-test --cpu-percent=50 --min=1 --max=10

create_load:
	kubectl -n k8s-demo run --generator=run-pod/v1 -it --rm load-generator --image=busybox /bin/sh
	# run:
	# while true; do wget -q -O- http://service-test.k8s-demo.svc.cluster.local; done
	#

describe_hpa:
	kubectl -n k8s-demo describe hpa service-test

get_hpa_v2:
	kubectl get hpa.v2beta2.autoscaling service-test -o yaml > /tmp/hpa-v2.yaml
	vim /tmp/hpa-v2.yaml

create_memory_hpa:
	kubectl -n k8s-demo apply -f service-test.memory.hpav2.yml


#
#
#
# CUSTOM METRICS AUTOSCALER
#
# - install prometheus via prometheus operator
# - deploy sample application which exposes custom metrics for request count
# - install prometheus adapter for kubernetes API
# - create HPA based on the custom metric

create_monitoring_namespace:
	kubectl create namespace monitoring || true

install_prometheus_operator:
	helm install -n monitoring prom-operator stable/prometheus-operator

prometheus_portforward:
	# if you want to open the prometheus webui, use port-forwarding
	# open localhost:9090 in your browser
	kubectl -n monitoring port-forward prometheus-prom-operator-prometheus-o-prometheus-0 9090

grafana_portforward:
	# default credentials: user: admin, password: prom-operator
	# open localhost:3000 in your browser
	kubectl port-forward $(shell kubectl get pods --selector=app=grafana -n monitoring --output=jsonpath="{.items..metadata.name}") -n monitoring 3000

deploy_graphql_server:
	# based on https://github.com/kotaicode/go-graphql-sqs-example
	kubectl -n k8s-demo create -f graphql-server.dpl.yml
	kubectl -n k8s-demo create -f graphql-server.svc.yml

graphql_server_portforward:
	kubectl -n k8s-demo port-forward $(shell kubectl get pods --selector=app=graphql-server -n k8s-demo --output=jsonpath="{.items..metadata.name}") 3333:3000

graphql_service_monitor:
	# instruct prometheus to scrape the graphql-service
	kubectl -n k8s-demo create -f graphql-server.servicemonitor.yml

prometheus_graphql_metrics:
	# first use port-forward to reach the prometheus service on localhost:9090
	open "http://localhost:9090/graph?g0.range_input=1h&g0.expr=rate(graphiql_requests_total%5B1m%5D)&g0.tab=0"

prometheus_adapter:
	# prometheus adapter bridges prometheus metrics with the kubernetes metrics API
	helm -n monitoring install prometheus-adapter --set prometheus.url=http://prom-operator-prometheus-o-prometheus stable/prometheus-adapter

prometheus_adapter_check:
	# the new custom metrics should be available in the kubernetes api
	kubectl get --raw /apis/custom.metrics.k8s.io/v1beta1

graphql_server_request_metric:
	# get the prometheus metrics via the kubernetes api
	kubectl get --raw "/apis/custom.metrics.k8s.io/v1beta1/namespaces/k8s-demo/pods/*/graphiql_requests?selector=app%3Dgraphql-server"

graphql_create_load:
	# first start port-fowarding with "make graphql_server_portforward"
	$(shell while true; do curl localhost:3333; sleep 1; done)

graphql_create_heavy_load:
	# first start port-fowarding with "make graphql_server_portforward"
	$(shell while true; do curl localhost:3333; done)

graphql_hpa:
	kubectl -n k8s-demo create -f graphql-server.hpa.yml

destroy:
	kubectl delete namespace k8s-demo
