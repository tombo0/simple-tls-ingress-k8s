#!/bin/bash

rm rootCA.key rootCA.pem server.crt server.csr.cnf server.key server.csr v3.ext server64.crt server64.key

openssl genrsa -des3 -out rootCA.key -passout file:pass.txt 2048

openssl req -x509 -new -nodes -key rootCA.key -sha256 -days 1460 -out rootCA.pem -subj "/C=ID/ST=West Java/L=Bandung/O=self/OU=self/emailAddress=test@minikube.local/CN=minikube.local" -passin file:pass.txt

cat <<EOF > server.csr.cnf
[req]
default_bits = 2048
prompt = no
default_md = sha256
distinguished_name = dn

[dn]
C=ID
ST=Jawa Barat
L=Bandung
O=self
OU=self                   
emailAddress=test@minikube.local
CN=minikube.local                                                                                     
EOF

cat <<EOF > v3.ext                                                
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = minikube.local
EOF

openssl req -new -sha256 -nodes -out server.csr -newkey rsa:2048 -keyout server.key -config server.csr.cnf

openssl x509 -req -in server.csr -CA rootCA.pem -CAkey rootCA.key -CAcreateserial -out server.crt -days 500 -sha256 -extfile v3.ext -passin file:pass.txt

cat server.crt | base64 > server64.crt

cat server.key | base64 > server64.key

sudo cp rootCA.pem /usr/local/share/ca-certificates

sudo update-ca-certificates