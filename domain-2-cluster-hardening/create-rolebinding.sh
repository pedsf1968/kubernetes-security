#!/bin/bash
ROOT_HOME_FOLDER=/root
ROOT_RBAC_FOLDER=$ROOT_HOME_FOLDER/rbac

createRBACRoleBinding(){
    RB_NAMESPACE=$1
    RB_NAME=$2
    RB_USER=$3
    RB_KIND=$4
    RB_ROLE=$5
    echo -e "\nCreate RBAC RoleBinding $RB_NAME"

    mkdir -p $ROOT_RBAC_FOLDER
    cd $ROOT_RBAC_FOLDER
    cat <<EOF | sudo tee ${RB_NAME}_RoleBinding.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: $RB_NAME
  namespace: $RB_NAMESPACE
subjects:
- kind: User
  name: $RB_USER
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: $RB_KIND
  name: $RB_ROLE
  apiGroup: rbac.authorization.k8s.io
EOF
    kubectl apply -f  ${RB_NAME}_RoleBinding.yaml
}

verifyRBACRoleBinding(){
    RB_NAMESPACE=$1
    RB_NAME=$2
    RB_USER=$3
    RB_ROLE=$4
    echo -e "\nVerify RBAC Role $RB_NAME"
    kubectl -n $RB_NAMESPACE get rolebinding | grep $RB_NAME
    kubectl -n $RB_NAMESPACE get rolebinding $RB_NAME -o yaml
    kubectl -n $RB_NAMESPACE describe rolebinding $RB_NAME
}

main(){
    ROLEBINDING_NAMESPACE=default
    ROLEBINDING_NAME=pod-reader
    ROLEBINDING_USER_NAME=john
    ROLEBINDING_ROLE_KIND=Role
    ROLEBINDING_ROLE=pod-reader

    createRBACRoleBinding $ROLEBINDING_NAMESPACE $ROLEBINDING_NAME $ROLEBINDING_USER_NAME $ROLEBINDING_ROLE_KIND $ROLEBINDING_ROLE
    verifyRBACRoleBinding $ROLEBINDING_NAMESPACE $ROLEBINDING_NAME

    ROLEBINDING_NAMESPACE=development
    ROLEBINDING_NAME=dev-pods
    ROLEBINDING_USER_NAME=john
    ROLEBINDING_ROLE_KIND=ClusterRole
    ROLEBINDING_ROLE=cluster-pod-reader

    createRBACRoleBinding $ROLEBINDING_NAMESPACE  $ROLEBINDING_NAME $ROLEBINDING_USER_NAME $ROLEBINDING_ROLE_KIND $ROLEBINDING_ROLE
    verifyRBACRoleBinding $ROLEBINDING_NAMESPACE $ROLEBINDING_NAME
}

main
