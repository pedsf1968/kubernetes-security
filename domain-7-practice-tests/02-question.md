# Question 2: AppArmor

Download the following profile into /etc/apparmor.d directory with the following command

https://raw.githubusercontent.com/zealvora/myrepo/master/cks/apparmor-profile

Load the profile into enforcing mode.
Create a deployment named pod-deploy with 2 replicas using the image of busybox.
The name of a container should be busybox-container
The busybox should run with the following command - sleep 36000
After deployment and PODS are created, associate the PODS with the AppArmor profile.