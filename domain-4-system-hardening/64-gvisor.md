### Documentation:

https://kubernetes.io/docs/concepts/containers/runtime-class/

#### Step 1 - Configure Docker:
```sh
sudo apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io
```
#### Step 2 - Install Configure Minikube:
```sh
wget https://github.com/kubernetes/minikube/releases/download/v1.16.0/minikube-linux-amd64
mv minikube-linux-amd64 minikube
chmod +x minikube
sudo mv ./minikube /usr/local/bin/minikube
```
```sh
curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
sudo mv kubectl /usr/local/bin
chmod +x /usr/local/bin/kubectl
```
```sh
sudo usermod -aG docker ubuntu
```
logout and login

####  Step 3 Start Minikube:
```sh
minikube start --container-runtime=containerd  --docker-opt containerd=/var/run/containerd/containerd.sock
```
####  Step 4 Enable gVisor addon:
```sh
minikube addons list
minikube addons enable gvisor
minikube addons list
```


# Runsc with containerd
## Install Runsc
```sh
# Install packages
sudo apt-get update && sudo apt-get install -y apt-transport-https ca-certificates curl  gnupg

# get repo key
curl -fsSL https://gvisor.dev/archive.key | sudo gpg --dearmor -o /usr/share/keyrings/gvisor-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/gvisor-archive-keyring.gpg] https://storage.googleapis.com/gvisor/releases release main" | sudo tee /etc/apt/sources.list.d/gvisor.list > /dev/null

# Install Runsc package
sudo apt-get update && sudo apt-get install -y runsc
```

## Configure

```sh
cat <<EOF | sudo tee /etc/containerd/config.toml
version = 2
[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
  runtime_type = "io.containerd.runc.v2"
[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runsc]
  runtime_type = "io.containerd.runsc.v1"
[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runsc.options]
  TypeUrl = "io.containerd.runsc.v1.options"
  ConfigPath = "/etc/containerd/runsc.toml"
EOF
```

```sh
sudo systemctl restart containerd
```


####  Step 5 - Explore gVisor:
```sh
kubectl get runtimeclass
```
```sh
vim runtimeclass.yaml
```
```sh
apiVersion: node.k8s.io/v1
kind: RuntimeClass
metadata:
  name: gvisor
handler: runsc
```
```sh
kubectl apply -f runtimeclass.yaml
```
```sh
vim gvisor-pod.yaml
```
```sh
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  runtimeClassName: gvisor
  containers:
  - image: nginx
    name: nginx
```
```sh
kubectl apply -f gvisor-pod.yaml
```

#### Create one more pod for seeing the difference in dmesg output:
```sh
kubectl run nginx-default --image=nginx
```

#### Verify dmesg output
```sh
kubectl exec -it nginx -- bash
dmesg
logout
```
```sh
kubectl exec -it nginx-default -- bash
dmesg
```

