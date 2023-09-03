
# Allow outbound traffic to other PODS in the same namespace only to the POD with label color=yello on Port 80
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
    - Egress
  egress:
    - from:
      - podSelector:
          matchLabels:
            color: yellow
      ports:
        - port: 80

