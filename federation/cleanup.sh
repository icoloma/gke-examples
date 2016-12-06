# Cleanup


# Remove everything
kubectl --context federation-cluster delete rs nginx
kubectl --context federation-cluster delete rs nginx-balanced
kubectl --context federation-cluster delete service nginx

# Consider stopping your federated cluster instead of deleting it
# WRONG: you would lose the IP addresses like thius
#gcloud container clusters resize icoloma-eu --zone europe-west1-b --size=0
#gcloud container clusters resize icoloma-us --zone us-east1-b --size=0

TODO: promote IP addresses to static and pause the GCE instances


# Uncomment to effectively remove
# gcloud container clusters delete icoloma-eu --zone europe-west1-b --async
# gcloud container clusters delete icoloma-us --zone us-east1-b
# rm -rf _output