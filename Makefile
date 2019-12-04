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



destroy:
	kubectl delete namespace k8s-demo
