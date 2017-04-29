 # Get the admin password for the newly created Jenkins cluster
 printf $(kubectl get secret --namespace default democi-jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode);echo

