#!/bin/bash
# A demo to show how Deployments work with Kubernetes 1.3
#
# This tutorial is available at 
# https://cloud.google.com/container-engine/docs/tutorials/persistent-disk/
#

# (optional) Show Application Launcher, as an example of how to 
# create Wordpress using plain VMs

#---------+---------+---------+---------+---------
# Create and connect to cluster
#---------+---------+---------+---------+---------

# Create cluster 
gcloud container clusters create icoloma-wppd --num-nodes 2

# Alternatively, if the cluster already exists
# gcloud container clusters get-credentials icoloma-wppd

gcloud compute instances list
gcloud container clusters list

# Create persistent disk
gcloud compute disks create --size 200GB mysql-disk

#---------+---------+---------+---------+---------
# Configure pods and services
#---------+---------+---------+---------+---------

# Create the MySQL pod and wait for it to appear
watch kubectl get pods
kubectl create -f mysql.yaml

# redirect mysql port to the local machine
kubectl port-forward mysql 3306
mysql --host=localhost --user=root --protocol=tcp --password=popotitos42 wordpress
SHOW TABLES
CREATE TABLE foo (id INTEGER);
SHOW TABLES

# Create the MyQL service and wait for it
kubectl create -f mysql-service.yaml
kubectl describe service mysql

# Create the Wordpress Deployment
kubectl create -f wordpress.yaml

# Create the service. Note the type: LoadBalancer setting, 
# which will create an external load balancer
kubectl create -f wordpress-service.yaml
kubectl get service wpfrontend

# Wait for the public IP to appear and connect with browser (port 80)

# See logs 
kubectl logs <wordpress-pod-id>

# Delete a pod and see it re-created
kubectl delete pod <pod-id>

#---------+---------+---------+---------+---------
# Scale to four replicas
#---------+---------+---------+---------+---------

kubectl scale --replicas=4 -f wordpress.yaml

#---------+---------+---------+---------+---------
# Upgrade to new version
#---------+---------+---------+---------+---------

# modify wordpress.yaml and change 
# version: 4.5 
# replicas: 4
watch kubectl get deployments
kubectl apply -f wordpress.yaml
kubectl rollout history deployment/wordpress
kubectl rollout undo deployment/wordpress

# Repeat a change, but this time pausing
kubectl apply -f wordpress.yaml && kubectl rollout pause deployment/wordpress
kubectl rollout resume deployment/wordpress

# Open the kubernetes UI 
gcloud container clusters describe icoloma-wppd | egrep '((username)|(password))'
kubectl cluster-info | grep kubernetes-dashboard

#---------+---------+---------+---------+---------
# Cleanup
#---------+---------+---------+---------+---------

# Cleanup
# gcloud compute firewall-rules delete wppd-world-80
# kubectl delete service wpfrontend
# kubectl delete service mysql
# kubectl delete pod wordpress
# kubectl delete pod mysql
gcloud container clusters delete icoloma-wppd
gcloud compute disks delete mysql-disk 

# Optional: Show the vitess config for kubernetes
# http://vitess.io/overview/