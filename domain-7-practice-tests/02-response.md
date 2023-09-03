# Download Apparmor profile
cd /etc/apparmor.d/
wget https://raw.githubusercontent.com/zealvora/myrepo/master/cks/apparmor-profile

# Load the profile into enforcing mode
apparmor_parser apparmor-profile
aa-status | grep k8s
   k8s-apparmor-example-deny-write

# Create deployment
## Create deployment template
kubectl create deploy pod-deploy --image=busybox --replicas=2 --dry-run=client -o yaml > pod-deploy.yaml
vim pod-deploy.yaml

## Modified pod-deploy.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: pod-deploy
  name: pod-deploy
spec:
  replicas: 2
  selector:
    matchLabels:
      app: pod-deploy
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: pod-deploy
    spec:
      containers:
      - image: busybox
        name: busybox-container
        command: [ "sleep", "36000"]
        resources: {}

## Lauch deployment
kubectl apply -f pod-deploy.yaml
deployment.apps/pod-deploy created

# Associate the PODS with the AppArmor profile
kubectl  edit deploy pod-deploy

cat /tmp/kubectl-edit-4083479222.yaml
# Please edit the object below. Lines beginning with a '#' will be ignored,
# and an empty file will abort the edit. If an error occurs while saving this file will be
# reopened with the relevant failures.
#
apiVersion: apps/v1
kind: Deployment
metadata:
  annotations:
    container.apparmor.security.beta.kubernetes.io: localhost/k8s-apparmor-example-deny-write
  labels:
    app: pod-deploy
  name: pod-deploy
  namespace: default
spec:
  progressDeadlineSeconds: 600
  replicas: 2
  revisionHistoryLimit: 10
  selector:
    matchLabels:
      app: pod-deploy
  strategy:
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
    type: RollingUpdate
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: pod-deploy
    spec:
      containers:
      - command:
        - sleep
        - "36000"
        image: busybox
        imagePullPolicy: Always
        name: busybox-container
        resources: {}

kubectl apply -f /tmp/kubectl-edit-4083479222.yaml
deployment.apps/pod-deploy configured

# Vérification
kubectl describe deployment.apps/pod-deploy | grep Annotations
Annotations:            container.apparmor.security.beta.kubernetes.io: localhost/k8s-apparmor-example-deny-write

