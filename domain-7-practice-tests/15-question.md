# Question 15 - gVisor

IMPORTANT:

For K8s v1.19, runtimeclass belonged to apiVersion: node.k8s.io/v1beta1 however, from K8s 1.20, it belongs to apiVersion: node.k8s.io/v1

For exams based on 1.19, make sure you remember this.

Question:

Create a new RunTimeClass named gvisor-class which should use the handler of runsc.
Create a deployment named gvisor-deploy with nginx image and 3 replicas.
Modify the deployment to ensure it uses the custom gvisor-class.