#!/bin/bash
ROOT_FOLDER=/root
ROOT_CERTIFICATES_FOLDER=$ROOT_FOLDER/certificates

removeAllCertificates(){
    echo -e "Remove all certificates in $ROOT_CERTIFICATES_FOLDER folder"
    rm -r $ROOT_CERTIFICATES_FOLDER
}

generateCACertificates(){
    echo -e "Create CA Certificates in $ROOT_CERTIFICATES_FOLDER folder"
    mkdir $ROOT_CERTIFICATES_FOLDER
    cd $ROOT_CERTIFICATES_FOLDER

    openssl genrsa -out ca.key 2048
    openssl req -new -key ca.key -subj "/CN=KUBERNETES-CA" -out ca.csr
    openssl x509 -req -in ca.csr -signkey ca.key -CAcreateserial  -out ca.crt -days 1000
    rm -f ca.csr
}

main(){
    removeAllCertificates
    generateCACertificates
}

main