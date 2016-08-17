# Cleanup
gcloud container clusters delete icoloma-eu --zone europe-west1-b 
gcloud container clusters delete icoloma-us --zone us-east1-b

git checkout -- clusters/icoloma-eu.yaml clusters/icoloma-us.yaml deployments/federation-apiserver.yaml