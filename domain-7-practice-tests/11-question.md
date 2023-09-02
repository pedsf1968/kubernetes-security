# Question 11 - Network Policy

Create a new namespace named custom-namespace

Create a new network policy named my-network-policy in the custom-namespace.

Requirements:

i) Network Policy should allow PODS within the custom-namespace to connect to each other only on Port 80. No other ports should be allowed.
 
ii) No PODs from outside of the custom-namespace should be able to connect to any pods inside the custom-namespace.