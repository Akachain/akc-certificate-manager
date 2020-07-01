#!/bin/bash
set -e

. utils.sh

function printHelp() {
    echo "Usage:"
    echo "  generate.sh <GenerateMode> <TypeOfTarget>"
    echo "    <GenerateMode>"
    echo "      - 'csr' - Generate certificate request"
    echo "      - 'cert' - Generate signed certificate"
    echo "      - 'auto' - Automatic generate from CSR to CRT"
    echo
    echo "    <TypeOfTarget>"
    echo "      - 'ca' - Intermediate CA"
    echo "      - 'peer' - Peer"
    echo "      - 'user' - User"
    echo
    echo " Examples:"
    echo "  generate.sh csr ca"
    echo "  generate.sh crt peer"
    echo "  generate.sh auto user"
}

function checkCSREnv() {
    local status=0
    if [ "$PRIV_KEY_PATH" == "" ]; then
        error "PRIV_KEY_PATH is required"
        status=1
    fi
    if [ "$CSR_CONFIG_PATH" == "" ]; then
        error "CSR_CONFIG_PATH is required"
        status=1
    fi
    if [ "$CSR_PATH" == "" ]; then
        error "CSR_PATH is required"
        status=1
    fi
    if [ $status -eq 1 ]; then
        exit $status
    fi
}

function checkCertEnv() {
    local status=0
    if [ "$CSR_PATH" == "" ]; then
        error "CSR_PATH is required"
        status=1
    fi
    if [ "$FABRIC_CA_SERVER_CERT" == "" ]; then
        error "FABRIC_CA_SERVER_CERT is required"
        status=1
    fi
    if [ "$FABRIC_CA_SERVER_KEY" == "" ]; then
        error "FABRIC_CA_SERVER_KEY is required"
        status=1
    fi
    if [ "$CERT_CONFIG_PATH" == "" ]; then
        error "CERT_CONFIG_PATH is required"
        status=1
    fi
    if [ "$CERT_PATH" == "" ]; then
        error "CERT_PATH is required"
        status=1
    fi
    if [ "$EXRIRY_DAYS" == "" ]; then
        error "EXRIRY_DAYS is required"
        status=1
    fi
    if [ $status -eq 1 ]; then
        exit $status
    fi
}

function generateCSR() {
    checkCSREnv
    set -x
    # CSR_CONFIG_PATH does not exist
    if [ ! -f "$CSR_CONFIG_PATH" ]; then
        # Generate CSR_CONFIG_PATH from template
        echo "$CERT_CONFIG_PATH does not exist"
        if [ "$CERT_SUBJ" != "" ]; then
            cat "$TEMPLATE_CONFIG_PATH/csr.conf" | sed -e "s/{{CERT_SUBJ}}/$CERT_SUBJ/g" > $CSR_CONFIG_PATH
        else
            cat "$TEMPLATE_CONFIG_PATH/csr.conf" | sed -e "s/{{CERT_SUBJ}}/$DEFAULT_CERT_SUBJ/g" > $CSR_CONFIG_PATH
        fi
    fi
    openssl req -new -key $PRIV_KEY_PATH -config $CSR_CONFIG_PATH -out $CSR_PATH
    set +x
}

function generateCert() {
    checkCertEnv

    # CERT_CONFIG_PATH does not exist
    if [ ! -f "$CERT_CONFIG_PATH" ]; then
        echo "$CERT_CONFIG_PATH does not exist"
        # Generate CERT_CONFIG_PATH from template
        if [ "$CERT_SUBJ" != "" ]; then
            cat "$TEMPLATE_CONFIG_PATH/crt.conf" | sed -e "s/{{CERT_SUBJ}}/$CERT_SUBJ/g" -e "s/{{SANS}}/$SANS/g" > $CERT_CONFIG_PATH
        else
            cat "$TEMPLATE_CONFIG_PATH/crt.conf" | sed -e "s/{{CERT_SUBJ}}/$DEFAULT_CERT_SUBJ/g" -e "s/{{SANS}}/$SANS/g" > $CERT_CONFIG_PATH
        fi
    fi
    set -x
    openssl x509 -req -in $CSR_PATH \
        -CA $FABRIC_CA_SERVER_CERT \
        -CAkey $FABRIC_CA_SERVER_KEY \
        -CAcreateserial -extfile $CERT_CONFIG_PATH -extensions req_ext \
        -out $CERT_PATH -days $EXRIRY_DAYS -sha256

    # Inspect cert
    openssl x509 -text -noout -in $CERT_PATH

    if [ "$TYPE" == "ca" ] && [ "$CHAIN_PATH" != "" ]; then
        # Generate ca-chain.pem
        cat $FABRIC_CA_SERVER_CERT $CERT_PATH > $CHAIN_PATH
        cat $CHAIN_PATH
    fi
    if [ "$TYPE" == "user" ] && [ "$CERT_STRING_PATH" != "" ]; then
        # Generate cert.txt
        awk '{printf "%s\\n", $0}' $CERT_PATH > $CERT_STRING_PATH
        cat $CERT_STRING_PATH
    fi
    set +x
}

MODE=$1
if [ "$MODE" == "csr" ]; then
    echo "Generate CSR"
    echo
elif [ "$MODE" == "cert" ]; then
    echo "Generate Certificate"
    echo
elif [ "$MODE" == "auto" ]; then
    echo "Auto Generate Certificate"
    echo
else
    printHelp
    exit 1
fi

TYPE=$2
if [ "$TYPE" == "user" ]; then
    TEMPLATE_CONFIG_PATH=$(dirname "$0")"/template/user"
    DEFAULT_CERT_SUBJ="0.OU = peer\n1.OU = Org1\n2.OU = akc\nCN = Org1"
elif [ "$TYPE" == "ca" ]; then
    TEMPLATE_CONFIG_PATH=$(dirname "$0")"/template/ca"
    DEFAULT_CERT_SUBJ="C = US\nST = North Carolina\nO = Hyperledger\nOU = client\nCN = rca-akc-admin"
else
    TEMPLATE_CONFIG_PATH=$(dirname "$0")"/template/peer"
    DEFAULT_CERT_SUBJ="C = VN\nST = Hanoi\nOU = peer\nCN = peer0"
fi

echo "Generate for type: $TYPE"

if [ "$MODE" == "csr" ]; then
    generateCSR
elif [ "$MODE" == "cert" ]; then
    generateCert
elif [ "$MODE" == "auto" ]; then
    echo "Generate CSR"
    generateCSR
    echo "Generate Certificate"
    generateCert
else
    printHelp
    exit 1
fi
