#!/bin/bash
ROOT_FOLDER=/root
ROOT_CERTIFICATES_FOLDER=$ROOT_FOLDER/certificates
ETCD_CERTIFICATES_FOLDER=$ROOT_FOLDER/certificates/etcd

removeAllCertificates(){
    echo -e "Remove all certificates in $ETCD_CERTIFICATES_FOLDER folder"
    rm -r $ETCD_CERTIFICATES_FOLDER
}


generateOpenSSLConfiguration(){
    echo -e "Generate OpenSSL configuration for ETCD Certificates"
    mkdir -p $ETCD_CERTIFICATES_FOLDER
    cd $ETCD_CERTIFICATES_FOLDER

    IP=$(ifconfig eth0 | grep 'inet ' | cut -d' ' -f10)
    cat > etcd.conf <<EOF
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names
[alt_names]
IP.1 = $IP
IP.2 = 127.0.0.1
EOF
}

generateCertificates(){
    mkdir -p $ETCD_CERTIFICATES_FOLDER
    cd $ETCD_CERTIFICATES_FOLDER

    cp $ROOT_CERTIFICATES_FOLDER/ca.crt .

    echo -e "Generate ETCD Server Certificates"
    openssl genrsa -out etcd.key 2048
    openssl req -new -key etcd.key -subj "/CN=etcd" -out etcd.csr -config etcd.conf
    openssl x509 -req -in etcd.csr -CA ca.crt -CAkey $ROOT_CERTIFICATES_FOLDER/ca.key -CAcreateserial -out etcd.crt -extensions v3_req -extfile etcd.conf -days 1000
    
    echo -e "Generate ETCD Client Certificates"
    openssl genrsa -out client.key 2048
    openssl req -new -key client.key -subj "/CN=client" -out client.csr
    openssl x509 -req -in client.csr -CA ca.crt -CAkey $ROOT_CERTIFICATES_FOLDER/ca.key -CAcreateserial -out client.crt -extensions v3_req  -days 1000
}

removeService(){
    echo -e "Remove ETCD Service"
    systemctl stop etcd
    systemctl disable etcd
    systemctl daemon-reload
    rm -r /var/lib/etcd
}


generateService(){
    echo -e "Generate ETCD Service"
    mkdir /var/lib/etcd
    chmod 700 /var/lib/etcd

    cat <<EOF | sudo tee /etc/systemd/system/etcd.service
[Unit]
Description=etcd
Documentation=https://github.com/coreos

[Service]
ExecStart=/usr/local/bin/etcd \
  --cert-file=$ETCD_CERTIFICATES_FOLDER/etcd.crt \
  --key-file=$ETCD_CERTIFICATES_FOLDER/etcd.key \
  --trusted-ca-file=$ETCD_CERTIFICATES_FOLDER/ca.crt \
  --client-cert-auth \
  --listen-client-urls https://127.0.0.1:2379 \
  --advertise-client-urls https://127.0.0.1:2379 \
  --data-dir=/var/lib/etcd
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
}

restartService(){
    echo -e "Restart ETCD Service"
    systemctl daemon-reload
    systemctl enable --now etcd
    systemctl status etcd
}

main(){
    removeAllCertificates
    generateOpenSSLConfiguration
    generateCertificates
    removeService
    generateService
    restartService
}

main