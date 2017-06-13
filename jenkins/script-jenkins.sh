# Kubernetes + Jenkins demo

Before the demo:

```bash
# create two clusters, one for jenkins and the other for the deployed app


# Create service account for the demo
# TODO: not working with the CLI yet, must be done with the web console instead (JSON key)
# gcloud iam service-accounts keys create jenkins-demo-service-account.json --iam-account=jenkins-demo-service-account@icoloma-42.iam.gserviceaccount.com 

# Assign permissions to the service account
gcloud projects add-iam-policy-binding icoloma-42 --member serviceAccount:jenkins-demo-service-account@icoloma-42.iam.gserviceaccount.com --role roles/editor

# Mount the JSON file as secret
kubectl create secret generic jenkins-demo-secrets --from-file=./jenkins-demo-service-account.json

# Create a separate cluster for the application
gcloud container clusters create demo-dev --num-nodes=2

```

During the demo:

```bash
# Show the jenkins chart to deploy
helm search jenkins

# Inspect the contents of the package
helm inspect stable/jenkins
helm inspect values stable/jenkins

# Install using our own values
helm install -f values.yaml stable/jenkins --name democi

# See the status of the deployment
helm status democi

# Get the password of the admin user
./get-pass.sh

# inspect the generated jenkins config
kubectl exec -it democi-jenkins-1138451357-bhfpc cat /var/jenkins_config/config.xml

# Upgrade the deployment
helm upgrade democi stable/jenkins --recreate-pods --values values.yaml
```

Open http://$SERVICE_IP:8777/login
Create multibranch or single branch pipeline. 
Add branch source, use https://github.com/icoloma/node-demo-app.git
Show Jenkinsfile


## GCB demo

In the node-demo-app/ folder:

* Show cloudbuild.yaml
* Make a change, and run:

``` bash
git commit -m 'Change' && git push && git tag v1.0 --force && git push --tags --force
```