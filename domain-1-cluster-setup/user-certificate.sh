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

if [[ -n "$3" ]]; then
    COPY_CERTIFICATES=True
fi

USER_CERTIFICATES_FOLDER=/home/$USER_NAME/certificates
ROOT_CERTIFICATES_FOLDER=/root/certificates

generateCertificate(){
    echo -e "\nGenerate $USER_NAME certificates"
    mkdir $ROOT_CERTIFICATES_FOLDER/$USER_NAME
    cd $ROOT_CERTIFICATES_FOLDER/$USER_NAME

    cp $ROOT_CERTIFICATES_FOLDER/ca.crt .
    
    openssl genrsa -out $USER_NAME.key 2048
    openssl req -new -key $USER_NAME.key -subj "/CN=$USER_NAME/O=$USER_GROUP" -out $USER_NAME.csr
    openssl x509 -req -in $USER_NAME.csr -CA ca.crt -CAkey $ROOT_CERTIFICATES_FOLDER/ca.key -CAcreateserial -out $USER_NAME.crt -days 1000
}

copyCertificates(){
    echo -e "\nMove Certificates to $USER_CERTIFICATES_FOLDER folder"
    mkdir -p $USER_CERTIFICATES_FOLDER

    cp $ROOT_CERTIFICATES_FOLDER/ca.crt $USER_CERTIFICATES_FOLDER/ca.crt
    cp $ROOT_CERTIFICATES_FOLDER/$USER_NAME.* $USER_CERTIFICATES_FOLDER/
    chown $USER_NAME:$USER_NAME  -R $USER_CERTIFICATES_FOLDER

}

verify(){
    echo -e "\nVerify"
    kubectl get secret --server=https://127.0.0.1:6443 --client-certificate $ROOT_CERTIFICATES_FOLDER/$USER_NAME/$USER_NAME.crt --certificate-authority $ROOT_CERTIFICATES_FOLDER/ca.crt --client-key $ROOT_CERTIFICATES_FOLDER/$USER_NAME/$USER_NAME.key
}

main(){
    generateCertificate
    verify
    
    if [[ -n "$COPY_CERTIFICATES" ]]; then
        copyCertificates
    fi

}

main
