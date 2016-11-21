#!/bin/bash
# A demo of how to orchestrate multiple containers with Federated Services
#
# This tutorial is available at 
# https://github.com/kelseyhightower/kubernetes-cluster-federation
#

# Check that everything is working fine
kubectl --context=federation-cluster get clusters


alias show_contexts='for c in $(kubectl config view -o jsonpath='{.contexts[*].name}'); do echo $c; done'
euContext=$(show_contexts | grep icoloma-eu)
usContext=$(show_contexts | grep icoloma-us)

# Leave these open, to see what happens
watch kubectl --context=federation-cluster get rs
watch kubectl --context=${euContext} get pods
watch kubectl --context=${usContext} get pods

# this should throw error. The federation cluster is not 100% API compatible, since 
# some things do not make sense 
watch kubectl --context=federation-cluster get pods

# Create the service on the federation cluster
kubectl --context=federation-cluster \
  create -f lab/nginx-rs.yaml
kubectl --context=federation-cluster \
  create -f lab/nginx-balanced.yaml

# At any point, to debug the federated controller manager or api server
kubectl logs -f --namespace=federation `kubectl --namespace federation get pods | grep controller-manager | cut -f 1 -d ' '`
kubectl logs -f --namespace=federation `kubectl --namespace federation get pods | grep api | cut -f 1 -d ' '` -c apiserver

# Create the Deployments

kubectl --context=gke_glass-turbine-504_us-east1-b_icoloma-us create -f deployments/nginx.yaml 
kubectl --context=gke_glass-turbine-504_us-east1-b_icoloma-us create -f deployments/nginx.yaml 





