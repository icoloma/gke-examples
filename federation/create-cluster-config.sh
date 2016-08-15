#!/bin/bash
# Create the federated cluster config, with two clusters (EU and US) and
# a federated-api service licing in one of the clusters in Europe
# You would usually do this manually. It's too long to do during a demo, so 
# have this ready before starting

# Usage: not as simple as ./create-cluster-config. You may probably want to run things manually. 
# output: clusters/icoloma-[eu,us] and kubeconfigs/icoloma[eu,us]
# Creates all federation services under namespace federation

set -e

# You will need to own a domain for this demo. Change this to your domain name.
export DOMAIN=icoloma.supercloud.co

# Get the list of context names from Kubernetes
alias show_contexts='for c in $(kubectl config view -o jsonpath='{.contexts[*].name}'); do echo $c; done'

createCluster() {
  clusterName=$1
  zone=$2

  gcloud container clusters create ${clusterName} --zone=${zone} --num-nodes=3

  # Context for EU cluster
  context=$(kubectl config view -o jsonpath='{.contexts[*].name}' | grep -o "[^ ]*${clusterName}")
  echo "Configuring $clusterName => ${context}"

  # Add cluster IP to clusters/file.yaml 
  clusterYamlFile=clusters/${clusterName}.yaml
  echo "Updating ${clusterYamlFile}"
  kubectl config use-context ${context}
  serverAddress=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')
  echo "Cluster IP is ${serverAddress}"
  sed -i "s|SERVER_ADDRESS|${serverAddress}|g" ${clusterYamlFile}

  # Create kubeconfig
  kubectl config view --flatten --minify > kubeconfigs/${clusterName}.yaml

}

# --- DNS config ---
# In which we register a domain name for our federated service, and bind
# to a Cloud DNS zone file

# The first time that you prepare for this lab, you should run these

# Create a dns zone file
gcloud dns managed-zones create icoloma-supercloud --dns-name $DOMAIN

# Register your domain (here, icoloma.supercloud.co) using domains.google.com 
# or any other, and when asked introduce these name servers:
gcloud dns managed-zones describe icoloma-supercloud

# -- End of DNS Config ---

# --- Create the clusters ---
# In which we create a cluster in EU and US, and configure a cluster definition 
# file (in clusters/) and secret (in kubeconfigs)

# Current project
# PROJECT=$(gcloud config list core/project 2> /dev/null | grep 'project =' | sed -r 's/project = (.*)/\1/')
# echo "Current project is $PROJECT"

# gcloud container clusters list

# Create both clusters
createCluster icoloma-eu europe-west1-b
createCluster icoloma-us us-east1-b
echo "All good. Check files in clusters/*.yaml and kubeconfigs/*.yaml"
cat clusters/*
cat kubeconfigs/*

# Choose one of your contexts and deploy the Federation Control Plane
federationContext=$(show_contexts | grep icoloma-eu)
kubectl config use-context ${federationContext}
kubectl create namespace federation
kubectl create -f services/federation-service.yaml

# Wait until the EXTERNAL-IP is populated
kubectl --namespace=federation get services 

# Create a file named known-tokens.csv with one line that will be used for 
# federation API secrets (replace the first field with a long, random token):
# XXXXXXXXXXXXXXXXXXX,admin,admin
cat known-tokens.csv

kubectl --namespace=federation create secret generic federation-apiserver-secrets --from-file=known-tokens.csv
kubectl --namespace=federation describe secrets federation-apiserver-secrets

# Get the Federated API Server IP and create the actual Deployment
export advertiseAddress=$(kubectl --namespace=federation get services federation-apiserver -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "Federated API address: ${advertiseAddress}"

sed -i "s|ADVERTISE_ADDRESS|${advertiseAddress}|g" deployments/federation-apiserver.yaml
kubectl create -f deployments/federation-apiserver.yaml

# Verify
kubectl --namespace=federation get deployments
kubectl --namespace=federation get pods

# Create kubeconfig for the federation server
kubectl config set-cluster federation-cluster --server=https://${advertiseAddress} --insecure-skip-tls-verify=true
kubectl config set-credentials federation-cluster --token="$(cut -f 1 -d , known-tokens.csv)"
kubectl config set-context federation-cluster --cluster=federation-cluster --user=federation-cluster
kubectl config use-context federation-cluster
kubectl config view --flatten --minify > kubeconfigs/federation.yaml

# create secret to access federation service
kubectl config use-context gke_glass-turbine-504_europe-west1-d_icoloma-eu
kubectl create secret generic federation-apiserver-secret --namespace=federation --from-file=kubeconfigs/federation.yaml

# Verify
kubectl --namespace=federation describe secrets federation-apiserver-secret

# Deploy the Federated Controller Manager
kubectl create -f deployments/federation-controller-manager.yaml
kubectl --namespace=federation get pods
