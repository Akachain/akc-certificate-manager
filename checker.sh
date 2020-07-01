#!/bin/bash

FILE_TYPE="crt"

. utils.sh

function printHelp() {
    echo "Usage:"
    echo "  checker.sh <Mode> [Flags]"
    echo "    <Mode>"
    echo "      - 'inspect' - Full details are output including the public key," \
        "signature algorithms, issuer and subject names, " \
        "serial number any extensions present and any trust settings"
    echo "      - 'check-expire' - Checks if the certificate expires"
    echo
    echo "    Flags:"
    echo "    -f <file path> - This specifies the input filename to read a certificate from."
    echo "    -t <file type> - Type of file: csr (CERTIFICATE REQUEST), crt (TRUSTED CERTIFICATE)"
    echo
    echo " Examples:"
    echo "  checker.sh inspect -f example/intermediate-ca/signcerts/ica-cert.pem -t crt"
    echo "  checker.sh inspect -f example/intermediate-ca/output/ica.csr -t csr"
    echo "  checker.sh check-expire -f example/intermediate-ca/signcerts/ica-cert.pem -t crt"

}

function inspectCert() {
    if [ "$FILE_TYPE" == "csr" ]; then
        detail=$(openssl req -in $FILE_PATH -noout -text)
    else
        detail=$(openssl x509 -text -noout -in $FILE_PATH)
    fi
    echo "Type: $FILE_TYPE"
    echo "Certificate Path: $FILE_PATH"
    echo "$detail"
}

function checkExpire() {
    if [ "$FILE_TYPE" != "crt" ]; then
        error "Unable to load certificate. Expecting: TRUSTED CERTIFICATE"
        exit 0
    fi
    enddate=$(openssl x509 -enddate -noout -in $FILE_PATH)
    expireInDay=$(openssl x509 -checkend 10 -noout -in $FILE_PATH)
    now=$(date -u)
    echo "Certificate Path: $FILE_PATH"
    echo "Certificate Status: $enddate"
    echo "Timenow: $now"
    echo $expireInDay

    # https://stackoverflow.com/a/31718838/8461456
    if openssl x509 -checkend 86400 -noout -in $FILE_PATH
    then
        echo "Certificate is good for another day!"
    else
        echo "Certificate has expired or will do so within 24 hours!"
        echo "(or is invalid/not found)"
    fi
}

MODE=$1
shift

while getopts "h:f:t:" opt; do
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
    esac
done
shift $((OPTIND -1))


if [ "$MODE" == "inspect" ]; then
    inspectCert
elif [ "$MODE" == "check-expire" ]; then
    checkExpire
else
    printHelp
fi

