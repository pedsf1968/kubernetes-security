# PodSecurityPolicy Deprecation: Past, Present, and Future
# Create PodSecurityPolicy  named psp-restrictive which denies privileged PODS
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: psp-restrictive
spec:
  privileged: false
  seLinux:
    rule: RunAsAny
  supplementalGroups:
    rule: RunAsAny
  runAsUser:
    rule: RunAsAny
  fsGroup:
    rule: RunAsAny
  volumes:
  - '*'

# Create a cluster role named psp-restrictive that uses the PSP.
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: psp-restrictive
rules:
- apiGroups: ['policy']
  resources: ['podsecuritypolicies']
  verbs:     ['use']
  resourceNames:
  - psp-restrictive

  # Create a Cluster Role Binding that associates the Cluster Role to SA named default in namespace test
  apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  creationTimestamp: null
  name: psp-restrictive
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: psp-restrictive
subjects:
- kind: ServiceAccount
  name: default
  namespace: test

# Enable PodSecurityPolicy Admission Controller
vim /etc/kubernetes/manifests/kube-apiserver.yaml

- --enable-admission-plugins=NodeRestriction,PodSecurityPolicy

# Verify if Deployment is successfully
kubectl create deployment nginx-deploy --image=nginx -n test
kubectl get pods - n test