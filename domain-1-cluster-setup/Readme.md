# Domain 1 - Cluster Setup

## 11-install-etcd.md
## 15-configure-ca.md
## 16-etcd-transit-encryption.md
## 17-etcd-client-auth.md
## 18-etcd-systemd.md
## 19-verify-binaries.md
## 20-configure-apiserver.md
## 21-apiserver-transit-encryption.md
## 23-token-authentication.md
## 24-certificate-auth-k8s.md
## 26-downside-token-auth.md
## 28-authorization.md
## 29-encryption-provider.md
## 30-audit-logs.md
## 31-kubeadm.md
## 32-taint.md
## 33-kubelet-security.md

# Scripts
## ca-install.sh 
- create CA certificate

## etcd-install.sh 
- create ETCD certificate
- launch ETCD
### Informations
- install-etcd.md
### Before execute
- ca-install.sh 

## kube-apiserver-install.sh
- create Kubernetes Api Server certificates
- launch Kubernetes Api Server certificates

### Before execute
- ca-install.sh 
- etcd-install.sh

## user-certificate.sh
-- Create user certificates 

### Before execute
- ca-install.sh 
- etcd-install.sh
- kube-apiserver-install.sh

## k8s-install-with-kubeadm.sh
- Install Kubernetes Controlplane Node
- Remove taint on Controlplane to run pod
### Before execute
- stop etcd service
- remove  /var/lib/etcd/members directory
- stop kube-apiserver service