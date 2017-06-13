
```
# Compile and upload
gcloud container builds submit . --tag "gcr.io/$(gcloud config list --format 'value(core.project)')/kubernetes" 
```