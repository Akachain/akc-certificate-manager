0. Prepare
    - Apply ca-cli.yaml: `kubectl apply -f ca-cli.yaml`
    - Exec to ca-cli: `kubectl exec -it ca-cli-0 bash`
    - Setup env:
    ```bash
    export ORG="org1"
    export DOMAIN="org1"
    export CA_CHAINFILE="/data/ica-chain.pem"
    export CA_HOST="ica-org1.org1:7054"
    export OUTPUT_PATH="/data/new/
    ```
1. Enroll CA Admin:
    ```bash
    export CA_ADMIN_USER_PASS=ica-${ORG}-admin:ica-${ORG}-adminpw
    export FABRIC_CA_CLIENT_HOME=/tmp/crypto-config/$ORG.$DOMAIN
    mkdir -p $FABRIC_CA_CLIENT_HOME
    export FABRIC_CA_CLIENT_TLS_CERTFILES=$CA_CHAINFILE
    fabric-ca-client enroll -u http://$CA_ADMIN_USER_PASS@$CA_HOST:7054
    ```
2. Register Identity:
    - Register Admin:
    ```bash
    fabric-ca-client register --id.name admin-${ORG} --id.secret admin-${ORG}pw --id.type admin --id.affiliation ""
    ```
    - Register Orderer:
    ```bash
    fabric-ca-client register -d --id.name orderer0-${ORG} --id.secret orderer0-${ORG}pw --id.type orderer --id.affiliation ""
    ```
    - Register Peer:
    ```bash
    fabric-ca-client register -d --id.name peer0-${ORG} --id.secret peer0-${ORG}pw --id.type peer --id.affiliation ""
    ```

3. Enroll to get cert:
    - Enroll Admin:
    ```bash
    fabric-ca-client enroll -u http://admin-${ORG}:admin-${ORG}pw@ica-${ORG}.${DOMAIN}:7054 -M ${OUTPUT_PATH}/${ORG}/users/admin/msp
    ```
    - Enroll Orderer:
    ```bash
    # MSP
    fabric-ca-client enroll -d -u http://orderer0-${ORG}:orderer0-${ORG}pw@ica-${ORG}.${DOMAIN}:7054 -M ${OUTPUT_PATH}/${ORG}/orderer0-${ORG}.${DOMAIN}/msp --csr.hosts orderer1-${ORG}.${DOMAIN}

    #TLS
    fabric-ca-client enroll -d --enrollment.profile tls -u http://orderer0-${ORG}:orderer0-${ORG}pw@ica-${ORG}.${DOMAIN}:7054 -M ${OUTPUT_PATH}/${ORG}/orderer0-${ORG}.${DOMAIN}/tls --csr.hosts orderer1-${ORG}.${DOMAIN}
    ```
    - Enroll Peer:
    ```bash
    #MSP
    fabric-ca-client enroll -d -u http://peer0-${ORG}:peer0-${ORG}pw@ica-${ORG}.${DOMAIN}:7054 -M ${OUTPUT_PATH}/${ORG}/peer0-${ORG}.${DOMAIN}/msp --csr.hosts peer0-${ORG}.${DOMAIN}
    #TLS
    fabric-ca-client enroll -d --enrollment.profile tls -u http://peer0-${ORG}:peer0-${ORG}pw@ica-${ORG}.${DOMAIN}:7054 -M ${OUTPUT_PATH}/${ORG}/peer0-${ORG}.${DOMAIN}/tls --csr.hosts peer0-${ORG}.${DOMAIN}
    ```

4. Copy to output

