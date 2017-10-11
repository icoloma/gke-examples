# A demo to show how Deployments work with Kubernetes

The full tutorial is available at 
https://cloud.google.com/container-engine/docs/tutorials/persistent-disk/

Create and connect to the cluster

```sh
# Create cluster 
gcloud container clusters create icoloma-wppd --num-nodes 2

# Alternatively, if the cluster already exists
# gcloud container clusters get-credentials icoloma-wppd

gcloud compute instances list
gcloud container clusters list

# Create persistent disk
gcloud compute disks create --size 200GB mysql-disk
```

Configure pods and services

```sh
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
```

Scale to four replicas

```sh
kubectl scale --replicas=4 -f wordpress.yaml
```

Upgrade to new version

```sh
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

# Open the web console of Google Cloud (console.google.com) and compare with the Kubernetes Dashboard 
kubectl proxy
xdg-open http://localhost:8001/ui
xdg-open https://console.cloud.google.com/kubernetes/list
```

Cleanup

```sh
# Cleanup
# gcloud compute firewall-rules delete wppd-world-80
# kubectl delete service wpfrontend
# kubectl delete service mysql
# kubectl delete pod wordpress
# kubectl delete pod mysql
gcloud container clusters delete icoloma-wppd
gcloud compute disks delete mysql-disk 

# Optional: Review the vitess config for kubernetes
# http://vitess.io/overview/
```