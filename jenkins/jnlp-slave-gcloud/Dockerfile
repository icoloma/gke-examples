# Jenkins slave image specific for this demo
FROM gcr.io/cloud-solutions-images/jenkins-k8s-slave

# Install node
USER root
RUN apt-get update && apt-get install -y -qq --no-install-recommends curl
RUN curl -sL https://deb.nodesource.com/setup_7.x | bash -
RUN apt-get install -y nodejs

# Update gcloud components
RUN gcloud components update

USER jenkins

