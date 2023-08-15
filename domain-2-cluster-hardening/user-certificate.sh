#!/bin/bash

if [[ -n "$1" ]]; then
    USER_NAME=$1
else
    USER_NAME=devops
fi

if [[ -n "$2" ]]; then
    USER_GROUP=$2
else
    USER_GROUP=developers
fi

K8S_CERTIFICATES_FOLDER=/etc/kubernetes/pki
K8S_CLUSTER_NAME=kubernetes
ROOT_CERTIFICATE_FOLDER=/root/certificates
USER_HOME_FOLDER=/home/$USER_NAME
USER_KUBE_FOLDER=$USER_HOME_FOLDER/.kube

removeOLDCertificates(){
    kubectl get csr | grep $USER_NAME 2> /dev/null 1> /dev/null
    if [[ $? -eq 0 ]]; then
        echo -e "Remove all CSR of $USER_NAME"
        kubectl delete csr $USER_NAME
    else
        echo -e "No old Certificate Signing Request for $USER_NAME"
    fi
    ls $ROOT_CERTIFICATES_FOLDER/$USER_NAME 2> /dev/null 1> /dev/null
    if [[ $? -eq 0 ]]; then
        echo -e "Remove all certificates of $USER_NAME"
        rm $ROOT_CERTIFICATES_FOLDER/$USER_NAME/*
    else
        echo -e "No old Certificates for $USER_NAME"
    fi
}

generateCSR(){
    echo -e "\nCreate Certificate Signing Request for $USER_NAME"
    ls $ROOT_CERTIFICATES_FOLDER/$USER_NAME 2> /dev/null 1> /dev/null
    if [[ $? -ne 0 ]]; then
        mkdir -p $ROOT_CERTIFICATES_FOLDER/$USER_NAME
    fi

    cd $ROOT_CERTIFICATES_FOLDER/$USER_NAME
    cp $K8S_CERTIFICATES_FOLDER/ca.crt .
    openssl genrsa -out $USER_NAME.key 2048
    openssl req -new -key $USER_NAME.key -subj "/CN=$USER_NAME/O=$USER_GROUP" -out $USER_NAME.csr
    REQUEST=$(cat $USER_NAME.csr | base64 | tr -d '\n')

    cat <<EOF | sudo tee $USER_NAME_csr.yaml
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: $USER_NAME
spec:
  groups:
  - system:authenticated
  request: $REQUEST
  signerName: kubernetes.io/kube-apiserver-client
  usages:
  - client auth
EOF
    kubectl apply -f $USER_NAME_csr.yaml
}

approveCSR(){
    echo -e "\nApprove Certificate Signing Request for $USER_NAME"
    cd $ROOT_CERTIFICATES_FOLDER/$USER_NAME

    kubectl certificate approve $USER_NAME
    kubectl get csr $USER_NAME -o jsonpath='{.status.certificate}' | base64 --decode > $USER_NAME.crt
}

createUser() {
    cat /etc/passwd | grep $USER_NAME 2> /dev/null 1> /dev/null
    if [[ $? -eq 0 ]]; then
        echo -e "User $USER_NAME already exist!"
    else
        echo -e "\nCreate user $USER_NAME on Linux system"
        useradd -m $USER_NAME -s /bin/bash -c "Kubernetes user"
    fi
}


copyCertificates(){
    echo -e "\nMove Certificates to $USER_KUBE_FOLDER folder"
    cd $ROOT_CERTIFICATES_FOLDER/$USER_NAME

    ls $USER_KUBE_FOLDER 2> /dev/null 1> /dev/null
    if [[ $? -eq 0 ]]; then
        for filename in ca.crt $USER_NAME.crt $USER_NAME.key; do
            rm $USER_KUBE_FOLDER/$filename
        done
    else
        mkdir -p $USER_KUBE_FOLDER
    fi

    for filename in ca.crt $USER_NAME.crt $USER_NAME.key; do
        cp $filename $USER_KUBE_FOLDER/
    done
    chown $USER_NAME:$USER_NAME  -R $USER_KUBE_FOLDER
}

verifyCertificates(){
    echo -e "\nVerify API access for $USER_NAME"
    SERVER_IP=$(ifconfig eth0 | grep 'inet ' | cut -d' ' -f10)
    COMMAND_ARGS="--server=https://$SERVER_IP:6443 --client-certificate $USER_KUBE_FOLDER/$USER_NAME.crt --certificate-authority $USER_KUBE_FOLDER/ca.crt --client-key $USER_KUBE_FOLDER/$USER_NAME.key"
    sudo -u $USER_NAME -- kubectl get pods $COMMAND_ARGS
}

generateKubeConfig(){
    echo -e "\nGenerate KubeConfig file for $USER_NAME"
    
    cd $ROOT_CERTIFICATES_FOLDER/$USER_NAME

    SERVER_IP=$(ifconfig eth0 | grep 'inet ' | cut -d' ' -f10)
    kubectl config set-cluster $K8S_CLUSTER_NAME --certificate-authority=$USER_KUBE_FOLDER/ca.crt --embed-certs=true --server=https://${SERVER_IP}:6443 --kubeconfig=$USER_NAME.kubeconfig
    kubectl config set-credentials $USER_NAME --client-certificate=$USER_KUBE_FOLDER/$USER_NAME.crt --client-key=$USER_KUBE_FOLDER/$USER_NAME.key --embed-certs=true --kubeconfig=$USER_NAME.kubeconfig
    kubectl config set-context default --cluster=$K8S_CLUSTER_NAME --user=$USER_NAME --kubeconfig=$USER_NAME.kubeconfig
    kubectl config use-context default --kubeconfig=$USER_NAME.kubeconfig

    cp $USER_NAME.kubeconfig $USER_KUBE_FOLDER/config
    chown $USER_NAME:$USER_NAME $USER_KUBE_FOLDER/config
}

verifyKubeconfig(){
    echo -e "\nVerify Kubeconfig  for $USER_NAME"
    sudo -u $USER_NAME kubectl get pods
}

main(){
    removeOLDCertificates
    generateCSR
    approveCSR
    createUser
    copyCertificates
    verifyCertificates
    verifyKubeconfig
    generateKubeConfig
}

main
