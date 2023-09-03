# Create a new RunTimeClass named gvisor-class which should use the handler of runsc.

vim gvisor-class.yaml

cat gvisor-class.yaml
iapiVersion: node.k8s.io/v1alpha1
kind: RuntimeClass
metadata:
  name: gvisor-class
spec:
  runtimeHandler: runc

# Create a deployment named gvisor-deploy with nginx image and 3 replicas.
kubectl create deploy gvisor-deploy  --image=nginx --replicas=3  --dry-run=client -o yaml > gvisor-deploy.yaml

vim gvisor-deploy.yaml
root@controlplane:~/manifest# cat gvisor-deploy.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: gvisor-deploy
  name: gvisor-deploy
spec:
  runtimeClassName: gvisor-class
  replicas: 3
  selector:
    matchLabels:
      app: gvisor-deploy
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: gvisor-deploy
    spec:
      containers:
      - image: nginx
        name: nginx
        resources: {}

