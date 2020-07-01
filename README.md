# Digital Certificate Manager
## I. Generate New Signed Certificate
### 1. Generate ICA
```shell
### Required ###
#### Generate CSR Input
export PRIV_KEY_PATH=/data/intermediate-ca/keystore/ica-key.pem
#### Generate CSR Output
export CSR_CONFIG_PATH=/data/intermediate-ca/output/csr.conf
export CSR_PATH=/data/intermediate-ca/output/ica.csr
#### Generate CRT Input
export FABRIC_CA_SERVER_CERT=/data/root-ca/signcerts/rca-cert.pem
export FABRIC_CA_SERVER_KEY=/data/root-ca/keystore/rca-key.pem
export EXRIRY_DAYS=1
#### Generate CRT Output
export CERT_CONFIG_PATH=/data/intermediate-ca/output/crt.conf
export CERT_PATH=/data/intermediate-ca/output/ca-cert.pem
export CHAIN_PATH=/data/intermediate-ca/output/ca-chain.pem

### Optional ###
export CERT_SUBJ="C = US\nST = North Carolina\nO = Hyperledger\nOU = client\nCN = rca-akc-admin"

### Run script ###
./main.sh generate auto ca
```

### 2. Generate Peer Cert
```shell
### Required ###
#### Generate CSR Input
export PRIV_KEY_PATH=/data/peer/keystore/peer-key.pem
#### Generate CSR Output
export CSR_CONFIG_PATH=/data/peer/output/csr.conf
export CSR_PATH=/data/peer/output/peer.csr
#### Generate CRT Input
export FABRIC_CA_SERVER_CERT=/data/intermediate-ca/signcerts/ica-cert.pem
export FABRIC_CA_SERVER_KEY=/data/intermediate-ca/keystore/ica-key.pem
export EXRIRY_DAYS=1
#### Generate CRT Output
export CERT_CONFIG_PATH=/data/peer/output/crt.conf
export CERT_PATH=/data/peer/output/peer-cert.pem

### Optional ###
export CERT_SUBJ="C = VN\nST = Hanoi\nOU = peer\nCN = peer0"

### Run script ###
./main.sh generate auto peer
```

### 3. Generate User Cert

#### a. How to get private key

- Read json file of user in crypto-path folder: ```cat admin/crypto-path/fabric-client-kv-org1/org1```. Find the value of the "signingIdentity". Example: ```"signingIdentity":"233446076089220cecaae13366ddc8d9f8d66b9f58fa6569e3bd0f544331eb6b"```

- Private key locate at folder crypto-store. Name is same with value of signingIdentity. Example: ```cat admin/crypto-store/fabric-client-kv-org1/233446076089220cecaae13366ddc8d9f8d66b9f58fa6569e3bd0f544331eb6b-priv```

#### b. Generate certificate

```shell
### Required ###
#### Generate CSR Input
export PRIV_KEY_PATH=/data/user/keystore/user-key.pem
#### Generate CSR Output
export CSR_CONFIG_PATH=/data/user/output/csr.conf
export CSR_PATH=/data/user/output/user.csr
#### Generate CRT Input
export FABRIC_CA_SERVER_CERT=/data/intermediate-ca/signcerts/ica-cert.pem
export FABRIC_CA_SERVER_KEY=/data/intermediate-ca/keystore/ica-key.pem
export EXRIRY_DAYS=1
#### Generate CRT Output
export CERT_CONFIG_PATH=/data/user/output/crt.conf
export CERT_PATH=/data/user/output/user-cert.pem
export CERT_STRING_PATH=/data/user/output/user-cert.txt

### Optional ###
export CERT_SUBJ="0.OU = peer\n1.OU = Org1\n2.OU = akc\nCN = Org1"

### Run script ###
./main.sh generate auto user
```

#### c. How to use a new cert

Copy content of $CERT_STRING_PATH and replace value of identity.certificate in crypto-path json file.

## II. Inspect and Check Expire Date Of Signed Certificate

### 1. Inspect
```bash
./main.sh checker inspect -f /data/intermediate-ca/signcerts/ica-cert.pem
```

### 2. Check expire date
```bash
./main.sh checker check-expire -f /data/intermediate-ca/signcerts/ica-cert.pem

./main.sh checker check-expire -f /data/root-ca/signcerts/rca-cert.pem
```