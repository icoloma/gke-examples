#!/bin/bash
# A bare-bones example to create a Docker container, upload to GCR and 
# deploy on Kubernetes
#
# This tutorial is available at 
# http://kubernetes.io/docs/hellonode/
#

# Configure project
export PROJECT_ID=<your-project-id>

# Show contents of server.js and test on localhost:8080
node server.js

# Image built and uploaded by running
docker build -t gcr.io/${PROJECT_ID}/hello-node .
gcloud docker push gcr.io/${PROJECT_ID}/hello-node

# Create container engine cluster
gcloud container clusters create hello-world --num-nodes 1 --machine-type g1-small

# Review status of cluster (add watch)
gcloud container clusters list
gcloud compute instances list

# deploy container
kubectl run hello-node --image=gcr.io/${PROJECT_ID}/hello-node --port=8080

# interactive container in Kubernetes 1.1 (type "exit" to exit)
# kubectl run -i --tty busybox --image=gcr.io/${PROJECT_ID}/hello-node --restart=Never -- sh 

# display data for this container
kubectl get pods
kubectl get nodes
kubectl get rc

# Create a Load Balancer to access the node
kubectl expose rc hello-node --create-external-load-balancer=true

kubectl get services

# test the public IP address with the browser

# scale the number of replicas
kubectl scale rc hello-node --replicas=3

kubectl get pods
kubectl get nodes

# debugging
kubectl logs <pod-name>

# inspect cluster and instance group in the web console

# get list of operations
gcloud container operations list

# cleanup
kubectl delete services hello-node
kubectl delete rc hello-node
gcloud container clusters delete hello-world
