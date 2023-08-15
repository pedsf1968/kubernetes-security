#!/bin/bash
ROOT_HOME_FOLDER=/root
ROOT_RBAC_FOLDER=$ROOT_HOME_FOLDER/rbac

createRBACRole(){
    R_NAMESPACE=$1
    R_NAME=$2
    R_API_GROUP=$3
    R_RESOURCES=$4
    R_VERBS=$5

    echo -e "\nCreate RBAC Role $R_NAMESPACE"

    mkdir -p $ROOT_RBAC_FOLDER
    cd $ROOT_RBAC_FOLDER
    cat <<EOF | sudo tee ${R_NAME}_Role.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: default
  name: pod-reader
rules:
- apiGroups: ["$ROLE_API_GROUP"]
  resources: [$ROLE_RESOURCES]
  verbs: [$ROLE_VERBS]
- apiGroups: [""]
  resources: ["pods/exec"]
  verbs: ["create"]
EOF
    kubectl apply -f  ${R_NAME}_Role.yaml
}

verifyRBACRole(){
    R_NAMESPACE=$1
    R_NAME=$2

    echo -e "\nVerify RBAC Role $R_NAME"
    kubectl -n $R_NAMESPACE get role | grep $R_NAME
    kubectl -n $R_NAMESPACE get role $R_NAME -o yaml
    kubectl -n $R_NAMESPACE describe role $R_NAME
}

main(){
    ROLE_NAMESPACE=default
    ROLE_NAME=pod-reader
    ROLE_API_GROUP=""
    ROLE_RESOURCES='"pods"'
    ROLE_VERBS='"get", "watch", "list","create"'

    createRBACRole $ROLE_NAMESPACE $ROLE_NAME $ROLE_API_GROUP $ROLE_RESOURCES $ROLE_VERBS
    verifyRBACRole $ROLE_NAMESPACE $ROLE_NAME
}

main
