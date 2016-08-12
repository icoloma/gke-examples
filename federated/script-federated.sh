#!/bin/bash
# A demo of how to orchestrate multiple containers with Federated Services
#
# This tutorial is available at 
# https://github.com/kelseyhightower/kubernetes-cluster-federation
#
# Recommended reading:
# https://github.com/kubernetes/kubernetes/blob/release-1.3/docs/design/federated-services.md
#

# You will need to own a domain for this demo. Change this to your domain name.
export DOMAIN=icoloma.supercloud.co

# --- First time ---
# The first time that you prepare for this lab, you should run these

# Create a dns zone file
gcloud dns managed-zones create icoloma-supercloud --dns-name $DOMAIN

# Register your domain (here, icoloma.supercloud.co) using domains.google.com 
# or any other, and introduce these name servers:
gcloud dns managed-zones describe icoloma-supercloud

# -- End of first time ---

# Create your clusters 
gcloud container clusters create icoloma-eu --zone=europe-west1-d --num-nodes=2 &
gcloud container clusters create icoloma-us --zone=us-east1-b --num-nodes=2

gcloud container clusters list

# TODO: do we need these? Set credentials in kubectl, but they are there already
# gcloud container clusters get-credentials icoloma-eu --zone=europe-west1-d
# gcloud container clusters get-credentials icoloma-us --zone=us-east1-b

# Get the list of context names for Kubernetes
for c in $(kubectl config view -o jsonpath='{.contexts[*].name}'); do echo $c; done


