#!/bin/bash

ROOT_HOME_FOLDER=/root
ROOT_RBAC_FOLDER=$ROOT_HOME_FOLDER/rbac

createRBACClusterRole(){
  CR_NAME=$1
  echo -e "\nCreate RBAC Role $ROLE_NAME"

  mkdir -p $ROOT_RBAC_FOLDER
  cd $ROOT_RBAC_FOLDER
  cat <<EOF | sudo tee ${CR_NAME}_ClusterRole.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: $CR_NAME
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "watch", "list","create"]
- apiGroups: [""]
  resources: ["pods/exec"]
  verbs: ["create"]
EOF
  kubectl apply -f  ${CR_NAME}_ClusterRole.yaml
}

verifyRBACClusterRole(){
  CR_NAME=$1
  kubectl get ClusterRole | grep $CR_NAME
  kubectl get ClusterRole $CR_NAME -o yaml
  kubectl describe ClusterRole $CR_NAME
}

main(){
  CLUSTERROLE_NAME=cluster-pod-reader
  
  createRBACClusterRole $CLUSTERROLE_NAME
  verifyRBACClusterRole $CLUSTERROLE_NAME
}

main
