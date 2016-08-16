#!/bin/bash
# A demo of how to orchestrate multiple containers with Federated Services
#
# This tutorial is available at 
# https://github.com/kelseyhightower/kubernetes-cluster-federation
#
# Recommended reading:
# https://github.com/kubernetes/kubernetes/blob/release-1.3/docs/design/federated-services.md
#

# WARNING: Before doing any demo, you should create your federated cluster. 
# THIS TAKES TIME, PLAN IN ADVANCE.

alias show_contexts='for c in $(kubectl config view -o jsonpath='{.contexts[*].name}'); do echo $c; done'

# Create the service on the federation cluster
kubectl --context=federation-cluster create -f services/nginx.yaml

# Verify
kubectl --context=federation-cluster get services
for i in $(show_contexts | grep icoloma); do 
  echo "Context: ${i}"
  kubectl --context=${i} get services
  echo -e
done


# Create the Deployments

kubectl --context=gke_glass-turbine-504_us-east1-b_icoloma-us create -f deployments/nginx.yaml 
kubectl --context=gke_glass-turbine-504_us-east1-b_icoloma-us create -f deployments/nginx.yaml 






# Cleanup
gcloud container clusters delete icoloma-eu --zone europe-west1-b
gcloud container clusters delete icoloma-us --zone us-east1-b
