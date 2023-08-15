#!/bin/bash
KUBERNETES_VERSION=1.24.2

FLANNEL_MANIFEST=https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
FLANNEL_CIDR=10.244.0.0/16
CALICO_MANIFEST=https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/tigera-operator.yaml
CALICO_CUSTOM_RESOURCES_MANIFEST=https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/custom-resources.yaml
CALICO_CIDR= 192.168.0.0/16

if [[ -n "$1" ]]; then
   KUBERNETES_NETWORKING=$1
else
   KUBERNETES_NETWORKING=flannel
fi

configureKernelModules(){
   echo -e "Configure Ubuntu Kernel modules for Containerd"
   cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF
   modprobe overlay
   modprobe br_netfilter
}

configureIpTables(){
   echo -e "Configure IP tables for Containerd"
   cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
   sysctl --system
}

containerdInstall(){
   echo -e "Install Containerd package"
   apt-get install -y containerd
}

containerdConfigure(){
   echo -e "Configure Containerd for SystemdCgroup"
   mkdir -p /etc/containerd
   containerd config default > /etc/containerd/config.toml
   sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
}

restartService(){
   echo -e "Restart $1 Service"
   systemctl daemon-reload
   systemctl enable $1
   systemctl restart $1
}

addKubernetesRepository() {
   echo -e "Add Kubernetes repository"
   apt-get update
   apt-get install -y apt-transport-https ca-certificates curl
   curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg
   echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
   apt-get update
}

installKubernetesPackages(){
   echo -e "Install Kubernetes packages with version $KUBERNETES_VERSION"
   KUBERNETES_PACKAGES_VERSION=$KUBERNETES_VERSION-00

   apt-cache madison kubeadm | head
   apt-get install -y kubelet=$KUBERNETES_PACKAGES_VERSION kubeadm=$KUBERNETES_PACKAGES_VERSION kubectl=$KUBERNETES_PACKAGES_VERSION cri-tools=$KUBERNETES_PACKAGES_VERSION
   apt-mark hold kubelet kubeadm kubectl
}

clusterInit() {
   echo -e "Initialise cluster with pod network $KUBERNETES_NETWORKING"
   case $KUBERNETES_NETWORKING in
      "calico")
         KUBERNETES_POD_NETWORK_CIDR=$FLANNEL_CIDR ;;
      "flannel")
         KUBERNETES_POD_NETWORK_CIDR=$FLANNEL_CIDR ;;
      *)
         KUBERNETES_POD_NETWORK_CIDR=$FLANNEL_CIDR ;;
   esac
   kubeadm init --pod-network-cidr=$KUBERNETES_POD_NETWORK_CIDR --kubernetes-version=$KUBERNETES_VERSION --node-name controlplane
}

copyConfig(){
   echo -e "Copy cluster configuration"
   mkdir -p $HOME/.kube
   cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
   chown $(id -u):$(id -g) $HOME/.kube/config
}

networkInstall(){
   echo -e "Install $KUBERNETES_NETWORKING networking"
   case $KUBERNETES_NETWORKING in
      "calico")
         kubectl apply -f $CALICO_MANIFEST
         kubectl apply -f $CALICO_CUSTOM_RESOURCES_MANIFEST ;;
      "flannel")
         kubectl apply -f $FLANNEL_MANIFEST ;;
      *)
         kubectl apply -f $FLANNEL_MANIFEST ;;
   esac  
}

removeControlplaneTaint(){
   echo -e "Remove Controlplane taint"
   kubectl taint node controlplane  node-role.kubernetes.io/master-
   kubectl taint node controlplane  node-role.kubernetes.io/control-plane:NoSchedule-
}

kubeletctlInstall(){
   echo -e "Install kubeletctl tools"
   cd /tmp
   curl -LO https://github.com/cyberark/kubeletctl/releases/download/v1.6/kubeletctl_linux_amd64
   chmod a+x ./kubeletctl_linux_amd64 
   mv ./kubeletctl_linux_amd64 /usr/local/bin/kubeletctl
}

main() {
   configureKernelModules
   configureIpTables
   containerdInstall
   containerdConfigure
   restartService containerd
   addKubernetesRepository
   installKubernetesPackages
   clusterInit
   copyConfig
   networkInstall
   removeControlplaneTaint
   kubeletctlInstall
}

main