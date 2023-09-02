# Question 6: Privileged and Immutability

Run the following manifest file.

kubectl apply -f https://raw.githubusercontent.com/zealvora/myrepo/master/cks/priv.yaml

There are a few PODS running in a namespace named selector.
For all the PODS that use privileged containers OR do not follow immutability, delete them.