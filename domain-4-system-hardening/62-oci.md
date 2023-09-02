### Documentation:

https://kubernetes.io/docs/setup/production-environment/container-runtimes/

https://www.cncf.io/projects/

#### Install containerd:
```sh
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF
```
```sh
modprobe overlay
modprobe br_netfilter
```
```sh
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
```
```sh
sysctl --system
```
```sh
apt-get install -y containerd
mkdir -p /etc/containerd
containerd config default > /etc/containerd/config.toml
systemctl restart containerd
```
#### Create Container with Containerd:

```sh
cd /etc/containerd/

ctr image pull docker.io/library/nginx:latest
ctr image ls
ctr container create docker.io/library/nginx:latest nginx
ctr container list
```
#### Get the snapshot to get the contents:
```sh
# Runc nead file system
mkdir /root/nginx-rootfs
ctr snapshot mounts nginx-rootfs/ nginx | bash
ls nginx-rootfs
```

#### Generate the config.yaml:
```sh
cd /root
rm -rf snap/
runc spec
cat config.json
# Change root path
sed -i 's/rootfs/nginx-rootfs/' config.json
```
Modify the config.yaml to include the name of nginx-rootfs

#### Create a container from runc:
```sh
runc run mycontainer
# in the container print id
id
```

#### Modify config 
```sh
# in the container print id
sed -i 's/uid\": 0/uid\": 1000/' config.json
sed -i 's/gid\": 0/gid\": 1000/' config.json
runc run new-container
id
```

