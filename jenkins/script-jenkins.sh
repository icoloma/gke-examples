# Kubernetes + Jenkins demo

```bash
# pre-work: create TLS certificate and key
openssl req -x509 -newkey rsa:2048 -keyout cert/key.pem -out cert/cert.pem -days 3000 -nodes

# pre-work: create TLS secret
kubectl create secret tls jenkins.cluster.local --cert=cert/cert.pem --keys=cert/key.pem





# Show the name of the jenkins chart
helm search jenkins

# Inspect the contents of the package
helm inspect stable/jenkins
helm inspect values stable/jenkins

# Install using our overriding values
helm install -f values.yaml stable/jenkins --name democi

# See the status of the deployment
helm status <release-name>

# Upgrade the deployment
helm upgrade democi stable/jenkins --recreate-pods --values values.yaml

````

Get the password from the command line with `./get-pass.sh`
Open http://$SERVICE_IP:8777/login
Put number of executor in the master config greater than 0 (e.g. 3)






Create multibranch or single branch pipeline. 
Add branch source, use https://github.com/icoloma/node-demo-app.git

Show Jenkinsfile
Show plugins in values.yaml and in the Jenkins console



Use travis CI command line?

SSL!!!!!!!!!!



Spinnaker on Cloud Launcher