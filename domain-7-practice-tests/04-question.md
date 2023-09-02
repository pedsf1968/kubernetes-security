# Question 4: Secrets

## Part 1 -
 
Run the following command:
 
i) kubectl apply -f https://raw.githubusercontent.com/zealvora/myrepo/master/cks/secrets.yaml
 
For the custom secret in the namespace kplabs-secret, fetch the content values in plain-text and store it to /tmp/secret.txt
 
## Part 2 -
 
Create a new secret named mount-secret with following contents
 
username=dbadmin
password=dbpasswd123
 
Mount the demo-secret to a POD named secret-pod. The secret should be available to /etc/mount-secret