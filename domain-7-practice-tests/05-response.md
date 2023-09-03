# Create a new Service Account named new-sa in the default namespace
kubectl create sa new-sa

# create role
kubectl create role sa-role --verb=list --resource=secrets

# create rolebinding
 kubectl create rolebinding sa-rolebinding --role=sa-role --serviceaccount=default:new-sa

# Create pod
kubectl run nginx-pod --image=nginx --dry-run=client -o yaml > nginx-pod.yaml

# Add service account
## Edit pod
vim nginx-pod.yaml

## Verify
cat nginx-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: nginx-pod
  name: nginx-pod
spec:
  serviceAccountName: new-sa
  containers:
  - image: nginx
    name: nginx-pod
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Always
status: {}

## Create pod
kubectl apply -f nginx-pod.yaml

# Verify
## Enter pod
kubectl exec -it nginx-pod -- bash

cd /run/secrets/kubernetes.io/serviceaccount
TOKEN=$(cat token)
curl -k -H "Authorization: Bearer $TOKEN" https://kubernetes/api/v1/namespaces/default/secrets


