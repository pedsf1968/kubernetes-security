# scan kube-apiserver image
## Get image version
kubectl -n kube-system  describe pod kube-apiserver-controlplane | grep -i image

## Scan image
trivy image --severity HIGH,CRITICAL registry.k8s.io/kube-apiserver:v1.25.12

# Scan nginx image
trivy image --severity HIGH,CRITICAL nginx:1.19.2
