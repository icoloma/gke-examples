# Jenkins slave image specific for this demo 
FROM gcr.io/cloud-solutions-images/jenkins-k8s-slave

USER root
RUN apt-get update && apt-get install -y -qq --no-install-recommends curl
RUN curl -sL https://deb.nodesource.com/setup_7.x | bash -
RUN apt-get install -y nodejs

#USER root
#RUN apt-get update && apt-get install -y -qq --no-install-recommends wget curl unzip python python-openssl docker.io
#RUN usermod -aG docker jenkins

# Add jenkins user to Docker group outside of the container
# see https://github.com/jenkinsci/docker/issues/263
#USER 0
#RUN DOCKER_GID=$(stat -c '%g' /var/run/docker.sock) && groupadd -for -g ${DOCKER_GID} docker && usermod -aG docker jenkins 

USER jenkins

