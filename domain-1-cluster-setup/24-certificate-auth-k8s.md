### Documentation Referred:

https://kubernetes.io/docs/reference/command-line-tools-reference/kube-apiserver/

#### Step 1 Creating Certificate for Alice:
```sh
cd /root/certificates
```
```sh
K8s_USER=devops
openssl genrsa -out $K8s_USER.key 2048
openssl req -new -key $K8s_USER.key -subj "/CN=$K8s_USER/O=developers" -out $K8s_USER.csr
openssl x509 -req -in $K8s_USER.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out $K8s_USER.crt -days 1000
```
#### Step 2 Set ClientCA flag in API Server:

```sh
nano /etc/systemd/system/kube-apiserver.service
```
```sh
--client-ca-file /root/certificates/ca.crt
```
```sh
systemctl daemon-reload
systemctl restart kube-apiserver
```
#### Step 3 Verification:
```sh
kubectl get secret --server=https://127.0.0.1:6443 --client-certificate /root/certificates/$K8s_USER.crt --certificate-authority /root/certificates/ca.crt --client-key /root/certificates/$K8s_USER.key
```
