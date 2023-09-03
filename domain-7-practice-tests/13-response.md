# Create a new namespace named color-namespace
kubectl create ns color-namespace

# Allow ingress traffic from pod labeled color=red in a namespace with label color=bright
vim my-network-policy.yaml

cat my-network-policy.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: my-network-policy
  namespace: default
spec:
  podSelector: {}
  policyTypes:
    - Ingress
  ingress:
    - from:
      - namespaceSelector:
          matchLabels:
            color: bright
      - podSelector:
          matchLabels:
            color: red

