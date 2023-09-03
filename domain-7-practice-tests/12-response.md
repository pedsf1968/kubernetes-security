# Create NetworkPolicy

vim my-network-policy.yaml

cat my-network-policy.yaml

apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: my-network-policy
  namespace: default
spec:
  podSelector:
    matchLabels:
      color: blue
  policyTypes:
    - Ingress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              color: red
      ports:
        - port: 80

