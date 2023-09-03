# Run the command:
 
kubectl apply -f https://raw.githubusercontent.com/zealvora/myrepo/master/cks/secrets.yaml

# Fetch secret data
## Get secret name
kubectl -n kplabs-secret get secrets
NAME          TYPE     DATA   AGE
demo-secret   Opaque   1      2m43s

## Get secret content
kubectl -n kplabs-secret get secrets demo-secret -o yaml
apiVersion: v1
data:
  admin: cGFzc3dvcmQ=
kind: Secret
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"v1","data":{"admin":"cGFzc3dvcmQ="},"kind":"Secret","metadata":{"annotations":{},"name":"demo-secret","namespace":"kplabs-secret"}}
  creationTimestamp: "2023-09-03T06:18:53Z"
  name: demo-secret
  namespace: kplabs-secret
  resourceVersion: "32232"
  uid: 17062107-0bb6-482f-8fd3-ab90924d7248
type: Opaque

## Decode secret value
echo "cGFzc3dvcmQ=" | base64 -d > /tmp/secret.txt
cat /tmp/secret.txt
password


# Create mount secret
## Create secret 
 kubectl create secret generic mount-secret --from-literal=username=dbadmin --from-literal=password=dbpasswd123

## Create POD named secret-pod
kubectl run secret-pod --image=nginx --dry-run=client -o yaml > secret-pod.yaml

## Mount secret
vim secret-pod.yaml

## file secret-pod.yaml
cat secret-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: secret-pod
  name: secret-pod
spec:
  containers:
  - image: nginx
    name: secret-pod
    volumeMounts:
      - name: secret-volume
        mountPath: "/etc/mount-secret"
        readOnly: true
  volumes:
    - name: secret-volume
      secret:
        secretName: mount-secret


