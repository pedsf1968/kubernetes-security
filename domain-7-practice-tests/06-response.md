
# Run the following manifest file.
## Get manifest
wget https://raw.githubusercontent.com/zealvora/myrepo/master/cks/priv.yaml

## Read manifest content
cat priv.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: selector

---

apiVersion: v1
kind: Pod
metadata:
  name: pod-1
  namespace: selector
spec:
  containers:
  - name: ubuntu
    image: ubuntu
    command: ["sleep","36000"]
    securityContext:
      readOnlyRootFilesystem: true
---

apiVersion: v1
kind: Pod
metadata:
  name: pod-2
  namespace: selector
spec:
  containers:
  - name: ubuntu
    image: ubuntu
    command: ["sleep","36000"]
---

apiVersion: v1
kind: Pod
metadata:
  name: pod-3
  namespace: selector
spec:
  containers:
  - name: ubuntu
    image: ubuntu
    command: ["sleep","36000"]
    securityContext:
       privileged: true

## Apply manifest
kubectl apply -f priv.yaml

# Remove privileged containers OR do not follow immutability

## Get pods names
kubectl get pods --all-namespaces

## Remove proivileged pods
kubectl -n selector get pods -o yaml | grep -i privileged
        {"apiVersion":"v1","kind":"Pod","metadata":{"annotations":{},"name":"pod-3","namespace":"selector"},"spec":{"containers":[{"command":["sleep","36000"],"image":"ubuntu","name":"ubuntu","securityContext":{"privileged":true}}]}}
        privileged: true
kubectl -n selector delete pod pod-3

## Find pod that follow immutability and remove other
kubectl -n selector get pods -o yaml | grep -i readOnlyRootFilesystem
        {"apiVersion":"v1","kind":"Pod","metadata":{"annotations":{},"name":"pod-1","namespace":"selector"},"spec":{"containers":[{"command":["sleep","36000"],"image":"ubuntu","name":"ubuntu","securityContext":{"readOnlyRootFilesystem":true}}]}}
        readOnlyRootFilesystem: true

kubectl -n selector delete pod pod-2

