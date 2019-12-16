# kubernetes networking and autoscaling example


this repository is intended to give some working examples for kubernetes networking and kubernetes autoscaling (based on cpu/memory as well as on custom metrics)

# requirements

- a (local) kubernetes cluster to test with, tested with kubernetes from docker for mac, but any other local kubernetes (e.g. minikube) should work.
  - if not using a local kubernetes cluster, make sure you have permissions to install software in the cluster, as well as creating load. Especially the autoscaling examples will generate load.
- local installation of helm (helm 3), and kubectl


# instructions

generic networking and CPU/memory Horizontal Pod Autoscaler examples use simple python based services, directly defined in the manifest files.

the prometheus metrics based example uses a pre-built docker image of a sample service from https://github.com/kotaicode/go-graphql-sqs-example with the docker image from https://hub.docker.com/r/kotaicode/go-graphql-sqs-example

this example collects the total request count to the graphql endpoint and the graphiql endpoint (the UI). For sake of simplicity in generating the load, we use the request count on the graphiql web UI as a metric to scale our pods on.



--- to be updated.

for now, follow the `Makefile` and the comments in the makefile
