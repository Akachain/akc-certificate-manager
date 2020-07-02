#!/bin/bash

FILE_TYPE="crt"
FOLDER_VERSION="cryptogen"

. utils.sh

function printHelp() {
    echo "Usage:"
    echo "  checker.sh <Mode> [Flags]"
    echo "    <Mode>"
    echo "      - 'inspect' - Full details are output including the public key," \
        "signature algorithms, issuer and subject names, " \
        "serial number any extensions present and any trust settings"
    echo "      - 'expire' - Checks if the certificate expires"
    echo
    echo "    Flags:"
    echo "    -f <file path> - This specifies the input filename to read a certificate from."
    echo "    -r <file type> - This specifies the input folder to read the certificates from."
    echo "    -t <file type> - Type of file: csr (CERTIFICATE REQUEST), crt (TRUSTED CERTIFICATE)"
    echo "    -v <file type> - Version of crypto-config maker"
    echo
    echo " Examples:"
    echo "  checker.sh inspect -f example/intermediate-ca/signcerts/ica-cert.pem -t crt"
    echo "  checker.sh inspect -f example/intermediate-ca/output/ica.csr -t csr"
    echo "  checker.sh expire -f example/intermediate-ca/signcerts/ica-cert.pem -t crt"
    echo "  checker.sh expire -r example-check-folder-version-cryptogen/ -v cryptogen"

}

function inspect() {
    if [ "$FILE_TYPE" == "csr" ]; then
        detail=$(openssl req -in $FILE_PATH -noout -text)
    else
        detail=$(openssl x509 -text -noout -in $FILE_PATH)
    fi
    echo "Type: $FILE_TYPE"
    echo "Certificate Path: $FILE_PATH"
    echo "$detail"
}

function checkFile() {
    if [ "$FILE_TYPE" != "crt" ]; then
        error "Unable to load certificate. Expecting: TRUSTED CERTIFICATE"
        exit 1
    fi
    enddate=$(openssl x509 -enddate -noout -in $FILE_PATH)
    now=$(date -u)
    echo "Certificate Path: $FILE_PATH"
    echo "Certificate Status: $enddate"
    echo "Timenow: $now"

    # https://stackoverflow.com/a/31718838/8461456
    if openssl x509 -checkend 86400 -noout -in $FILE_PATH
    then
        valid "Certificate is good for another day!"
    else
        invalid "Certificate has expired or will do so within 24 hours!"
        invalid "(or is invalid/not found)"
    fi
}

function checkFolder() {
    . scripts/get_cert_path.sh
    echo "Checking folder $FOLDER_PATH version $FOLDER_VERSION..."
    getCerts
    for cert in "${LIST_CERT_IN_FOLDER[@]}"; do
        echo
        echo "#################################"
        FILE_PATH=$cert
        TYPE=cert
        # echo $FILE_PATH
        checkFile
    done
}

function expire() {

    if [ "$FILE_PATH" == "" ] && [ "$FOLDER_PATH" == "" ]; then
        error "Must specify file or folder of crypto-config certificates"
        printHelp
        exit 1
    fi

    if [ "$FILE_PATH" != "" ]; then
        checkFile
    fi

    if [ "$FOLDER_PATH" != "" ]; then
        checkFolder
    fi
}

MODE=$1
shift

while getopts "h:f:t:r:v:" opt; do
    case ${opt} in
    h | \?) 
        printHelp
        exit 0
        ;;
    t)
        FILE_TYPE=$OPTARG
        ;;
    f)
        FILE_PATH=$OPTARG
        ;;
    r)
        FOLDER_PATH=$OPTARG
        ;;
    v)
        FOLDER_VERSION=$OPTARG
        ;;
    esac
done
shift $((OPTIND -1))


if [ "$MODE" == "inspect" ]; then
    inspect
elif [ "$MODE" == "expire" ]; then
    expire
else
    printHelp
fi

