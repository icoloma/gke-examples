#!/bin/bash
# Open a browser to the Kubernetes dashboard
# Use: ./console.sh <cluster-name>

clusterName=$1
username=$(gcloud container clusters describe ${clusterName} | egrep 'username' | sed 's/\s*username:\s*//')
password=$(gcloud container clusters describe ${clusterName} | egrep 'password' | sed 's/\s*password:\s*//')
#kubectl cluster-info | grep kubernetes-dashboard
masterAddress=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}' | sed -e 's/https\:\/\///')
url="https://${username}:${password}@${masterAddress}/ui"
echo "Opening Kubernetes dashboard"
xdg-open "${url}"