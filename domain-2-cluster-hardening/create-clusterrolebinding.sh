#!/bin/bash

ROOT_HOME_FOLDER=/root
ROOT_RBAC_FOLDER=$ROOT_HOME_FOLDER/rbac

createRBACClusterRoleBinding(){
    CRB_NAME=$1
    CRB_USER=$2
    CRB_ROLE=$3
    echo -e "\nCreate RBAC Cluster Role Binding $CRB_NAME"

    mkdir -p $ROOT_RBAC_FOLDER
    cd $ROOT_RBAC_FOLDER
    cat <<EOF | sudo tee ${CRB_NAME}_ClusterRoleBinding.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: $CRB_NAME
subjects:
- kind: User
  name: $CRB_USER
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: $CRB_ROLE
  apiGroup: rbac.authorization.k8s.io
EOF
    kubectl apply -f  ${CRB_NAME}_ClusterRoleBinding.yaml
}

verifyRBACClusterRoleBinding(){
  CRB_NAME=$1
  kubectl get ClusterRoleBinding | grep $CRB_NAME
  kubectl describe ClusterRoleBinding $CRB_NAME
  kubectl get ClusterRoleBinding $CRB_NAME -o yaml
}

main(){
  CLUSTERROLEBINDING_NAME=read-pods-global
  CLUSTERROLE_NAME=cluster-pod-reader
  USER_NAME=john

  createRBACClusterRoleBinding $CLUSTERROLEBINDING_NAME $USER_NAME $CLUSTERROLE_NAME
  verifyRBACClusterRoleBinding $CLUSTERROLEBINDING_NAME
}

main
