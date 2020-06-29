# Digital Certificate Manager
## Generate ICA
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
#### Generate CRT Output
export CERT_CONFIG_PATH=/data/intermediate-ca/output/crt.conf
export CERT_PATH=/data/intermediate-ca/output/ca-cert.pem
export CHAIN_PATH=/data/intermediate-ca/output/ca-chain.pem
export EXRIRY_DAYS=1

### Optional ###
export CERT_SUBJ="C = US\nST = North Carolina\nO = Hyperledger\nOU = client\nCN = rca-akc-admin"

### Run script ###
./script.sh auto ca
```



