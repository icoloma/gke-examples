#!/bin/bash
# Create the federated cluster config, with two clusters (EU and US) and
# a federated-api service living in one of the clusters in Europe
# You would do this before the demo, since it's a long manual process.

# Usage: not as simple as ./create-cluster-config. You may probably want to run things manually. 
# Output:
# _output/output/clusters/icoloma-[eu,us] Cluster definition file
# _output/kubeconfigs/icoloma[eu,us] Credentials to connect to the cluster
#
# All federation services are created under namespace federation
#
# Full set of instructions available at 
# http://kubernetes.io/docs/admin/federation/

set -e

# You will need to own a domain for this demo. Change this to your domain name.
export DOMAIN=icoloma.supercloud.co

# --- DNS config ---
# In which we register a domain name for our federated service, and bind
# to a Cloud DNS zone file

# The first time that you prepare for this lab, you should run these

# Create a dns zone file
gcloud dns managed-zones create icoloma-supercloud --dns-name $DOMAIN

# Register your domain (here, icoloma.supercloud.co) using domains.google.com 
# or any other, and when asked introduce these name servers:
gcloud dns managed-zones describe icoloma-supercloud

# --- Create the clusters ---
# In which we create a cluster in EU and US, and configure a cluster definition 
# file (in clusters/) and secret (in kubeconfigs)
mkdir -p _output/clusters _output/federation _output/deployments 

createCluster() {
  clusterName=$1
  zone=$2

  # Federation cluster will need permission to modify DNS records
  gcloud container clusters create ${clusterName} --zone=${zone} --num-nodes=2 \
  --scopes "storage-ro,logging-write,monitoring-write,service-control,service-management,https://www.googleapis.com/auth/ndev.clouddns.readwrite"
  gcloud container clusters get-credentials ${clusterName} --zone=${zone}

  # Context for EU cluster
  context=$(kubectl config view -o jsonpath='{.contexts[*].name}' | grep -o "[^ ]*${clusterName}")
  echo "Configuring $clusterName => ${context}"

  # Create cluster definition file clusters/file.yaml 
  echo "Updating clusters/${clusterName}.yaml"
  kubectl config use-context ${context}
  serverAddress=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')
  echo "Cluster IP is ${serverAddress}"
  cat > _output/clusters/${clusterName}.yaml <<EOF
apiVersion: federation/v1beta1
kind: Cluster
metadata:
  name: ${clusterName}
spec:
  serverAddressByClientCIDRs:
    - clientCIDR: "0.0.0.0/0"
      serverAddress: "${serverAddress}"
  secretRef:
    name: ${clusterName}
EOF

  # Create kubeconfig with credentials for that cluster
  mkdir -p _output/kubeconfigs/${clusterName}/
  kubectl config view --flatten --minify > _output/kubeconfigs/${clusterName}/kubeconfig

}

# Create both clusters
createCluster icoloma-eu europe-west1-b
createCluster icoloma-us us-east1-b
echo "All good. Check files in clusters/*.yaml and kubeconfigs/*.yaml"
ls -lR kubeconfigs/*/kubeconfig
cat clusters/*

# --- Deploy the Federation API Server ---
# In which we create a namespace for federation and deploy the Federated API Server

# Get the context names for Federation
alias show_contexts='for c in $(kubectl config view -o jsonpath='{.contexts[*].name}'); do echo $c; done'
export federationContext=$(show_contexts | grep icoloma-eu)
echo "Federation context: ${federationContext}"

# create a namespace
kubectl --context="${federationContext}" \
  create -f ns/federation.yaml

# Create API Server and wait until the EXTERNAL-IP is populated
kubectl create -f services/federation-apiserver.yamlTODO REVIEW CONTENTS
watch kubectl --namespace=federation get services 

# Create a file named known-tokens.csv with one line that will be used for 
# federation API secrets (replace the first field with a long, random token):
# XXXXXXXXXXXXXXXXXXX,admin,admin
cat known-tokens.csv

kubectl --context=${federationContext} \
  --namespace=federation \
  create secret generic federation-apiserver-secrets \
  --from-file=known-tokens.csv 
kubectl --context=${federationContext} \
  --namespace=federation \
  describe secrets federation-apiserver-secrets

# Create persistent disk for etcd
kubectl --context=${federationContext} \
  --namespace=federation \
  create -f pvc/federation-apiserver-etcd.yaml

# Verify
kubectl --context=${federationContext} \
  --namespace=federation \
  get pvc

# Get the Federated API Server public IP and create the actual Deployment
advertiseAddress=$(kubectl --context=${federationContext} \
  --namespace=federation \
  get services federation-apiserver \
  -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "Federated API address: ${advertiseAddress}"

sed "s|ADVERTISE_ADDRESS|${advertiseAddress}|g" deployments/federation-apiserver.yaml > _output/deployments/federation-apiserver.yaml
kubectl --context=${federationContext} \
  --namespace=federation \
  create -f _output/deployments/federation-apiserver.yaml

# Verify
watch kubectl --context=${federationContext} \
  --namespace=federation \
  get pods
watch kubectl  --context=${federationContext} \
  --namespace=federation \
  get deployments

# --- Deploy the Federated Controller Manager ---
# Things typically break here, and it's usually because of 
# lack of credentials. DOUBLE CHECK YOUR CREDENTIALS 
# in kubeconfig

# Create kubeconfig for the federation server
kubectl config set-cluster federation-cluster \
  --server=https://${advertiseAddress} \
  --insecure-skip-tls-verify=true
kubectl config set-credentials federation-cluster \
  --token="$(cut -f 1 -d , known-tokens.csv)"
kubectl config set-context federation-cluster \
  --cluster=federation-cluster \
  --user=federation-cluster

mkdir -p _output/kubeconfigs/federation-apiserver
kubectl config use-context federation-cluster
kubectl config view --flatten --minify > _output/kubeconfigs/federation-apiserver/kubeconfig
kubectl config use-context ${federationContext}

# create secret to access federation service
kubectl --context=${federationContext} \
  --namespace=federation \
  create secret generic federation-apiserver-kubeconfig \
  --from-file=_output/kubeconfigs/federation-apiserver/kubeconfig
kubectl --context=${federationContext} \
  --namespace=federation \
  describe secrets federation-apiserver-kubeconfig

# Deploy the Federated Controller Manager
kubectl --context=${federationContext} \
  --namespace=federation \
  create -f deployments/federation-controller-manager.yaml
watch kubectl --context=${federationContext} \
  --namespace=federation \
  get pods

# Leave this open while creating clusters and deploying services
# First download stern from https://github.com/wercker/stern
stern --namespace federation '.*'

# Show the logs of one of the pieces
# invoke: logs 
#logs() {
#  kubectl logs -f --namespace=federation `kubectl --namespace federation get pods | grep $1 | cut -f 1 -d ' '` $2 $3
#}
#logs controller-manager
#logs api -c apiserver

# --- Register clusters with Federated API server ---
# We register both clusters with the API Server

kubectl --context=${federationContext} \
  --namespace=federation \
  create secret generic icoloma-eu \
  --from-file=_output/kubeconfigs/icoloma-eu/kubeconfig

kubectl --context=${federationContext} \
  --namespace=federation \
  create secret generic icoloma-us \
  --from-file=_output/kubeconfigs/icoloma-us/kubeconfig


kubectl --context=federation-cluster \
  create -f _output/clusters/icoloma-eu.yaml
kubectl --context=federation-cluster \
  create -f _output/clusters/icoloma-us.yaml

# Verify
kubectl --context=federation-cluster get clusters

#
# AWESOME STUFF STARTS HERE. Go to script-federated.sh.
#

