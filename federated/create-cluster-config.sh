#!/bin/bash
# Create the cluster config file in ./clusters
# Not really interesting. You would usually do this manually

# Usage: 
# ./create-cluster-config europe-west1-d icoloma-eu

# Current project
PROJECT=$(gcloud config list core/project | grep 'project =' | sed -r 's/project = (.*)/\1/')

# Context for EU cluster
CONTEXT=$(kubectl config view -o jsonpath='{.contexts[*].name}' | grep -o '[^ ]*europe[^ ]*icoloma')

# Add cluster IP to clusters/file.yaml 
kubectl config use-context $CONTEXT
serverAddress=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')
sed -i "s|SERVER_ADDRESS|${serverAddress}|g" clusters/icoloma-eu.yaml

# Create kubeconfig
kubectl config view --flatten --minify > kubeconfigs/kubeconfig-eu
