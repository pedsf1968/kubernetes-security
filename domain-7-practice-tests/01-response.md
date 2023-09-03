# Create directory
mkdir -p /etc/kubernetes/controlconf

# Create admission controller config file
## Command
vim /etc/kubernetes/controlconf/config.yaml
## config.yaml
apiVersion: apiserver.config.k8s.io/v1
kind: AdmissionConfiguration
plugins:
  - name: ImagePolicyWebhook
    configuration:
      imagePolicy:
        kubeConfigFile: /etc/kubernetes/controlconf/config.kubeconfig
        allowTTL: 50
        denyTTL: 50
        retryBackoff: 500
        defaultAllow: false

# Create admission controller kubeconfig
## Command
vim /etc/kubernetes/confcontrol/config.kubeconfig

##  config.kubeconfig
apiVersion: v1
kind: Config
clusters:
- name: image-webhook
  cluster:
    certificate-authority: /etc/kubernetes/pki/ca.crt
    server: https://webhook.kplabs.internal

users:
- name: api-server
  user:
    client-certificate: /etc/kubernetes/pki/apiserver.crt
    client-key: /etc/kubernetes/pki/apiserver.key

contexts:
- context:
    cluster: image-webhook
    user: apiserver
  name: demo-context
current-context: demo-context

# AddImagePolicyWebhook configuration
## Command
vim /etc/kubernetes/manifests/kube-apiserver.yaml

## kube-apiserver.yaml
### kube-apiserver command
    - --admission-control-config-file=/etc/kubernetes/confcontrol/config.yaml
    - --enable-admission-plugins=NodeRestriction,ImagePolicyWebhook 

### volumeMounts
    - name: imagewebhook
      mountPath: /etc/kubernetes/controlconf
      readOnly: true
### volumes
  - name: imagewebhook
    hostPath:
      path: /etc/kubernetes/controlconf
      type: DirectoryOrCreate

# Launch pod
## Command
kubectl run nginx --image=nginx
kubectl run nginx --image=nginx
Error from server (Forbidden): pods "nginx" is forbidden: Post "https://webhook.kplabs.internal/?timeout=30s": dial tcp: lookup webhook.kplabs.internal on 172.31.0.2:53: no such host

## Get logs
kubectl run nginx --image=nginx 2>/tmp/error.log
cat /tmp/error.log
Error from server (Forbidden): pods "nginx" is forbidden: Post "https://webhook.kplabs.internal/?timeout=30s": dial tcp: lookup webhook.kplabs.internal on 172.31.0.2:53: no such host
