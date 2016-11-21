# Cleanup

kubectl --context federation-cluster delete rs nginx
kubectl --context federation-cluster delete rs nginx-balanced

gcloud container clusters delete icoloma-eu --zone europe-west1-b --async
gcloud container clusters delete icoloma-us --zone us-east1-b
rm -rf _output