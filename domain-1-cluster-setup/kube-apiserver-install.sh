#!/bin/bash
ROOT_FOLDER=/root
ROOT_CERTIFICATES_FOLDER=$ROOT_FOLDER/certificates
KUBERNETES_LIB_FOLDER=/var/lib/kubernetes
KUBERNETES_LOGGING_FOLDER=/var/log/kubernetes
ETCD_CERTIFICATES_FOLDER=$ROOT_CERTIFICATES_FOLDER/etcd

APISERVER_CERTIFICATES_FOLDER=$ROOT_CERTIFICATES_FOLDER/apiserver
APISERVER_AUDIT_LOG_FOLDER=$KUBERNETES_LOGGING_FOLDER

APISERVER_ENCRYPTION_CONF=encryption-at-rest.yaml

# Metadata/Request/RequestResponse
APISERVER_AUDIT_LOG_LEVEL=Metadata
APISERVER_AUDIT_LOG_CONF=apiserver-logging.yaml
APISERVER_AUDIT_LOG_FILE=apiserver-audit.log 
APISERVER_AUDIT_LOG_MAXAGE=30  
APISERVER_AUDIT_LOG_MAXBACKUP=10  
APISERVER_AUDIT_LOG_MAXSIZE=100 



removeAllCertificates(){
    echo -e "Remove all certificates in $APISERVER_CERTIFICATES_FOLDER folder"
    rm -r $APISERVER_CERTIFICATES_FOLDER
}

softwareInstallation(){
    echo "Software installation"
    mkdir -p /tmp/binaries
    cd /tmp/binaries
    wget https://dl.k8s.io/v1.24.2/kubernetes-server-linux-amd64.tar.gz
    tar -xzvf kubernetes-server-linux-amd64.tar.gz
    cd /tmp/binaries/kubernetes/server/bin/
    mkdir /usr/local/bin/
    cp kube-apiserver kubectl /usr/local/bin/
    rm -r /tmp/binaries
}

generateOpenSSLConfiguration(){
    echo "Generate OpenSSL configuration for Kubernetes API Server Certificates"
    mkdir -p $APISERVER_CERTIFICATES_FOLDER
    cd $APISERVER_CERTIFICATES_FOLDER

    IP=$(ifconfig eth0 | grep 'inet ' | cut -d' ' -f10)

    cat <<EOF | sudo tee kube-apiserver.conf
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = kubernetes
DNS.2 = kubernetes.default
DNS.3 = kubernetes.default.svc
DNS.4 = kubernetes.default.svc.cluster.local
IP.1 = 127.0.0.1
IP.2 = $IP
IP.3 = 10.0.0.1
EOF
}

generateCertificates(){
    mkdir -p $APISERVER_CERTIFICATES_FOLDER
    cd $APISERVER_CERTIFICATES_FOLDER

    cp $ROOT_CERTIFICATES_FOLDER/ca.crt .
 
    # Generate Client Certificate for API Server (ETCD Client):
    echo "Generate Client Certificates for ETCD"
    openssl genrsa -out apiserver.key 2048
    openssl req -new -key apiserver.key -subj "/CN=kube-apiserver" -out apiserver.csr
    openssl x509 -req -in apiserver.csr -CA ca.crt -CAkey $ROOT_CERTIFICATES_FOLDER/ca.key -CAcreateserial -out apiserver.crt -extensions v3_req  -days 1000

    # Generate Certificates for API Server TLS
    echo "Generate Server Certificates for API"
    openssl genrsa -out kube-api.key 2048
    openssl req -new -key kube-api.key -subj "/CN=kube-apiserver" -out kube-api.csr -config kube-apiserver.conf
    openssl x509 -req -in kube-api.csr -CA ca.crt -CAkey $ROOT_CERTIFICATES_FOLDER/ca.key -CAcreateserial  -out kube-api.crt -extensions v3_req -extfile kube-apiserver.conf -days 1000

    # Generate Service Account Certificates
    echo "Generate Service Account Certificates"
    openssl genrsa -out service-account.key 2048
    openssl req -new -key service-account.key -subj "/CN=service-accounts" -out service-account.csr
    openssl x509 -req -in service-account.csr -CA ca.crt -CAkey $ROOT_CERTIFICATES_FOLDER/ca.key -CAcreateserial  -out service-account.crt -days 100

}

generateEncryptionKey(){
    echo -e "Generate encryption key for ETCD"
    mkdir $KUBERNETES_LIB_FOLDER
    cd $KUBERNETES_LIB_FOLDER
    ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)

    cat > $APISERVER_ENCRYPTION_CONF <<EOF
kind: EncryptionConfig
apiVersion: v1
resources:
  - resources:
      - secrets
    providers:
      - aescbc:
          keys:
            - name: key1
              secret: ${ENCRYPTION_KEY}
      - identity: {}
EOF
}


generateAuditPolicy(){
    echo -e "Generate logging configuration"
    mkdir $APISERVER_AUDIT_LOG_FOLDER
    cd $APISERVER_CERTIFICATES_FOLDER
    cat <<EOF | sudo tee $APISERVER_AUDIT_LOG_CONF
apiVersion: audit.k8s.io/v1
kind: Policy
rules:
- level: $APISERVER_AUDIT_LOG_LEVEL
EOF
}

removeService(){
    echo -e "Remove kube-apiserver Service"
    systemctl stop kube-apiserver
    systemctl disable kube-apiserver
    systemctl daemon-reload
}


generateService(){
    echo -e "Generate ETCD Service"
    IP=$(ifconfig eth0 | grep 'inet ' | cut -d' ' -f10)

    cat <<EOF | sudo tee /etc/systemd/system/kube-apiserver.service
[Unit]
Description=Kubernetes API Server
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-apiserver \
--authorization-mode=RBAC \
--advertise-address=$IP \
--etcd-cafile=$APISERVER_CERTIFICATES_FOLDER/ca.crt \
--etcd-certfile=$APISERVER_CERTIFICATES_FOLDER/apiserver.crt \
--etcd-keyfile=$APISERVER_CERTIFICATES_FOLDER/apiserver.key \
--etcd-servers=https://127.0.0.1:2379 \
--service-account-key-file=$APISERVER_CERTIFICATES_FOLDER/service-account.crt \
--service-account-signing-key-file=$APISERVER_CERTIFICATES_FOLDER/service-account.key \
--service-account-issuer=https://127.0.0.1:6443 \
--service-cluster-ip-range=10.0.0.0/24 \
--tls-cert-file=$APISERVER_CERTIFICATES_FOLDER/kube-api.crt \
--tls-private-key-file=$APISERVER_CERTIFICATES_FOLDER/kube-api.key \
--client-ca-file=$APISERVER_CERTIFICATES_FOLDER/ca.crt \
--encryption-provider-config=$KUBERNETES_LIB_FOLDER/$APISERVER_ENCRYPTION_CONF \
--audit-policy-file=$APISERVER_CERTIFICATES_FOLDER/$APISERVER_AUDIT_LOG_CONF \
--audit-log-path=$APISERVER_AUDIT_LOG_FOLDER/$APISERVER_AUDIT_LOG_FILE \
--audit-log-maxage=$APISERVER_AUDIT_LOG_MAXAGE \
--audit-log-maxbackup=$APISERVER_AUDIT_LOG_MAXBACKUP  \
--audit-log-maxsize=$APISERVER_AUDIT_LOG_MAXSIZE 


[Install]
WantedBy=multi-user.target
EOF
}

restartService(){
    echo -e "Restart ETCD Service"
    systemctl daemon-reload
    systemctl enable --now kube-apiserver
    systemctl status kube-apiserver
}

main(){
    #softwareInstallation
    generateOpenSSLConfiguration
    generateEncryptionKey
    generateCertificates
    generateAuditPolicy
    removeService
    generateService
    restartService
}

main
