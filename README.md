./script.sh auto user


### ICA
export PRIV_KEY_PATH=/data/ica/ica-key.pem
export CSR_CONFIG_PATH=/data/ica/csr.conf
export CSR_PATH=/data/ica/ica.csr
export FABRIC_CA_SERVER_CERT=/data/rca/rca-cert.pem
export FABRIC_CA_SERVER_KEY=/data/rca/rca-key.pem
export CERT_CONFIG_PATH=/data/ica/crt.conf
export CERT_PATH=/data/ica/ca-cert.pem
export CHAIN_PATH=/data/ica/ca-chain.pem
./script.sh auto ca

