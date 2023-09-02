### Falco Documentation:

https://falco.org/docs/getting-started/installation/



#### Installation Steps:
```sh
# curl -s https://falco.org/repo/falcosecurity-3672BA8F.asc | apt-key add -
curl -fsSL https://falco.org/repo/falcosecurity-packages.asc | sudo gpg --dearmor -o /usr/share/keyrings/falco-archive-keyring.gpg
# echo "deb https://dl.bintray.com/falcosecurity/deb stable main" | tee -a /etc/apt/sources.list.d/falcosecurity.list
sudo cat >>/etc/apt/sources.list.d/falcosecurity.list <<EOF
deb [signed-by=/usr/share/keyrings/falco-archive-keyring.gpg] https://download.falco.org/packages/deb stable main
EOF
# apt-get -y install linux-headers-$(uname -r)
apt-get update
sudo apt install -y dkms make linux-headers-$(uname -r)
# If you use the falco-driver-loader to build the BPF probe locally you need also clang toolchain
sudo apt install -y clang llvm
# You can install also the dialog package if you want it
sudo apt install -y dialog

apt-get install -y falco
```
#### Start falco:
```sh
falco
```
#### In other console:
```sh
cat /etc/shadow
```
See logs in first console

#### Sample Rules tested:
```sh
kubectl run nginx --image=nginx
kubectl exec -it nginx -- bash
```
```sh
mkdir /bin/tmp-dir
cat /etc/shadow
```
