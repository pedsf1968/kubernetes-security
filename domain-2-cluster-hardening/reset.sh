#!/bin/bash
ROOT_FOLDER=/root
RBAC_FOLDER=$ROOT_FOLDER/rbac

KUBERNETES_VERSION=1.24.2
KUBERNETES_POD_NETWORK_CIDR=10.244.0.0/16

removeServices(){
    systemctl stop etcd
    systemctl disable etcd
    rm -r /var/lib/etcd/member

    systemctl stop kube-apiserver
    systemctl disable kube-apiserver
}

resetCluster(){
    kubeadm reset
    kubeadm init --pod-network-cidr=$KUBERNETES_POD_NETWORK_CIDR --kubernetes-version=$KUBERNETES_VERSION --node-name controlplane

    mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config
}

configureCluster(){
    kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
    kubectl taint node controlplane  node-role.kubernetes.io/master-
    kubectl taint node controlplane  node-role.kubernetes.io/control-plane:NoSchedule-
}


configureUsers(){
    ./user-certificate.sh john developers copy
}

createObjects(){
    kubectl create namespace development
    kubectl create namespace production
    kubectl apply -f $RBAC_FOLDER/pod-reader_Role.yaml
    kubectl apply -f $RBAC_FOLDER/pod-reader_RoleBinding.yaml
    kubectl apply -f $RBAC_FOLDER/cluster-pod-reader_ClusterRole.yaml  
    kubectl apply -f $RBAC_FOLDER/cluster-pod-reader_ClusterRoleBinding.yaml
}

main(){
    removeServices
    resetCluster
    clusterConfigure
    configureCluster
    createObjects
}

main