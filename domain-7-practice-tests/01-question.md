# Question 1: ImagePolicyWebhook

All the images that are deployed need to be verified from an external webhook.
URL of the webhook is webhook.kplabs.internal
If the webhook is down, the images should not be allowed.
All files should be stored in /etc/kubernetes/confcontrol
For CA certificate, use the ca.crt available under /etc/kubernetes/pki directory
For user certificate and key, use the API Certificate and Key configured under pki directory.
Create a POD named nginx from an image of nginx
If POD fails to start, copy the error log and store it to /tmp/error.log