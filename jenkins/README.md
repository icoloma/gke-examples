# Kubernetes + Jenkins demo

Before the demo, create a secret with the key to your service account:

```bash
# Create a service account for the demo
# TODO: not working with the CLI yet, must be done with the web console instead 
# (retrieve the JSON key for your service account)
# gcloud iam service-accounts keys create jenkins-demo-service-account.json --iam-account=jenkins-demo-service-account@icoloma-42.iam.gserviceaccount.com 

# Assign permissions to the service account
gcloud projects add-iam-policy-binding icoloma-42 --member serviceAccount:jenkins-demo-service-account@icoloma-42.iam.gserviceaccount.com --role roles/editor

# Mount the JSON file as secret
kubectl create secret generic jenkins-demo-secrets --from-file=./jenkins-demo-service-account.json

# You will need a separate cluster for the application
gcloud container clusters create demo-dev --num-nodes=2

```

Create a Jenkins installation:

```bash
# Review the jenkins chart to deploy
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
kubectl exec -it [pod_name] cat /var/jenkins_config/config.xml

# get the public IP of your Jenkins service
kubectl get services
```

Open http://$SERVICE_IP:8777/login
Create multibranch or single branch pipeline. 
Add branch source, use https://github.com/icoloma/node-demo-app.git
Review Jenkinsfile

When done, clean up the deployment:

```sh
helm delete --purge democi
```

## GCB demo

We will use our own Git Source Repository included in our GCP project ([see docs](https://cloud.google.com/source-repositories/docs/quickstart)). 

First, let's clone the node-demo-app repository and add to our repository. 

```sh
# Clone the repository from Github
git clone git@github.com:icoloma/node-demo-app.git
cd node-demo-app

# Configure gcloud authentication for git and add new remote repository 
git config credential.helper gcloud.sh
gcloud source repos create [YOUR_REPO]
git remote add google https://source.developers.google.com/p/[PROJECT_ID]/r/[YOUR_REPO]

# Push the current code to master
git push -u google master
```

Go to the [GCB configuration page](https://console.cloud.google.com/gcr/triggers?project=koliseo2) and create a build trigger pointing to the new repository. Choose a tag trigger.

In the node-demo-app/ folder:

* Review cloudbuild.yaml
* Make any change, and run:

``` bash
git commit -am 'Change' && git push && git tag v1.0 --force && git push --tags --force
```