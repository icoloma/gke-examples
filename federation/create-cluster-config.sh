#!/bin/bash
# Create the cluster config file in ./clusters
# Not really interesting. You would usually do this manually

# Usage: 
# ./create-cluster-config 
# output: clusters/icoloma-[eu,us] and kubeconfigs/icoloma[eu,us]

# Current project
PROJECT=$(gcloud config list core/project 2> /dev/null | grep 'project =' | sed -r 's/project = (.*)/\1/')
echo "Project is $PROJECT"

createCluster() {
  clusterName=$1

  # Context for EU cluster
  CONTEXT=$(kubectl config view -o jsonpath='{.contexts[*].name}' | grep -o "[^ ]*${clusterName}")
  echo "Configuring $clusterName => $CONTEXT"

  # Add cluster IP to clusters/file.yaml 
  CLUSTER_FILE=clusters/${clusterName}.yaml
  echo "Updating $CLUSTER_FILE"
  kubectl config use-context $CONTEXT
  serverAddress=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')
  echo "Cluster IP is $serverAddress"
  sed -i "s|SERVER_ADDRESS|${serverAddress}|g" $CLUSTER_FILE

  # Create kubeconfig
  kubectl config view --flatten --minify > kubeconfigs/${clusterName}.yaml

}

createCluster icoloma-eu
createCluster icoloma-us
echo "All good. Check files in clusters/*.yaml and kubeconfigs/*.yaml"