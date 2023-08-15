#!/bin/bash

ROOT_FOLDER=/root
ROOT_INGRESS_FOLDER=$ROOT_FOLDER/ingress


createIngressController(){
  kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/baremetal/deploy.yaml
}

generateCertificates(){
  I_NAME=$1
  I_HOST=$2
  echo -e "\nGenerate Certificate for Ingress Resource $I_NAME with $I_HOST"
  mkdir -p $ROOT_INGRESS_FOLDER
  cd $ROOT_INGRESS_FOLDER
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ${I_NAME}_ingress.key -out ${I_NAME}_ingress.crt -subj "/CN=${I_HOST}/O=security"

  kubectl create secret tls ${I_NAME}-tls-cert --key ${I_NAME}_ingress.key --cert ${I_NAME}_ingress.crt
}


verifyCertificates(){
  I_NAME=$1
  echo -e "\nVerify Certificate for Ingress Resource $I_NAME"
  kubectl get secret ${I_NAME}-tls-cert -o yaml
}

createIngressResource(){
  I_NAME=$1
  I_HOST=$2
  I_SERVICE_NAME=$3
  I_SERVICE_PORT=$4

  echo -e "\nCreate Ingress Resource $I_NAME"

  mkdir -p $ROOT_INGRESS_FOLDER
  cd $ROOT_INGRESS_FOLDER
  cat <<EOF | sudo tee ${I_NAME}_Ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: $I_NAME
  annotations:
     nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  tls:
  - hosts:
      - $I_HOST
    secretName: ${I_NAME}-tls-cert
  rules:
  - host: $I_HOST
    http:
      paths:
      - pathType: Prefix
        path: "/"
        backend:
          service:
            name: $I_SERVICE_NAME
            port:
              number: $I_SERVICE_PORT
EOF
  kubectl apply -f  ${I_NAME}_Ingress.yaml
}

verifyIngressResource(){
  I_NAME=$1
  echo -e "\nVerify Ingress Resource $I_NAME"
  kubectl get ingress | grep $I_NAME
  kubectl get ingress $I_NAME -o yaml
  kubectl describe ingress $I_NAME
}

main(){
#  createIngressController
  INGRESS_NAME=demo-ingress
  INGRESS_HOST=example.internal
  INGRESS_SERVICE_NAME=example-svc
  INGRESS_SERVICE_PORT=80

  generateCertificates $INGRESS_NAME $INGRESS_HOST
  verifyCertificates $INGRESS_NAME
  createIngressResource $INGRESS_NAME $INGRESS_HOST $INGRESS_SERVICE_NAME $INGRESS_SERVICE_PORT
  verifyIngressResource $INGRESS_NAME
}

main
