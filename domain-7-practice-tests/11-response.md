# Create a new namespace named custom-namespace
kubectl create ns custom-namespace

# Create a new network policy named my-network-policy in the custom-namespace.
vim my-network-policy.yaml

cat my-network-policy.yaml

apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: my-network-policy
  namespace: custom-namespace
spec:
  podSelector: {}
  policyTypes:
    - Ingress
  ingress:
    - from:
        - podSelector: {}
      ports:
        - port: 80
