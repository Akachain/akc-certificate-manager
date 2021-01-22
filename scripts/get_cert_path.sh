#!/bin/bash

LIST_CERT_IN_FOLDER=()

function getUniqCert() {
    local listPemPath=$(find $FOLDER_PATH -name "*.pem")
    local listCrtPath=$(find $FOLDER_PATH -name "*.crt")
    local arrayCertPath=($listPemPath)
    arrayCertPath+=(${listCrtPath[@]})
    local arrayCertPathUniq=()
    local detectDuplicate=()
    for certPath in "${arrayCertPath[@]}"; do
        local certName=$(basename $certPath)
        # Detect private key or chain from list
        if [[ $certName == *"key"* ]] || [[ $certName == *"chain"* ]]; then
            continue
        fi
        # Check duplicate certificate
        local fingerPrint=$(openssl x509 -noout -fingerprint -md5 -inform pem -in $certPath)
        local notExists=0
        for i in "${detectDuplicate[@]}"; do
            if [ "$fingerPrint" == "$i" ]; then
                notExists=1
            fi
        done
        if [ $notExists -eq 0 ]; then
            detectDuplicate+=("$fingerPrint")
            arrayCertPathUniq+=("$certPath")
        fi
    done

    LIST_CERT_IN_FOLDER+=(${arrayCertPathUniq[@]})
}

function getCerts() {
    # Check FOLDER_PATH exists
    if [ ! -d "$FOLDER_PATH" ]; then
        error "Folder $FOLDER_PATH DOES NOT exists."
        exit 1
    fi

    # Getting Unique Certificates
    getUniqCert

    echo "Detect ${#LIST_CERT_IN_FOLDER[@]} certificates"
}