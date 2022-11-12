#!/bin/bash
VAULT_RETRIES=5
echo "Vault is starting..."
until vault status > /dev/null 2>&1 || [ "$VAULT_RETRIES" -eq 0 ]; do
        echo "Waiting for vault to start...: $((VAULT_RETRIES--))"
        sleep 1
done
echo "Authenticating to vault..."
vault login token=vault-plaintext-root-token
echo "Enable PKI"
vault secrets enable pki
echo "set the lifetime of certs"
vault secrets tune -max-lease-ttl=87600h pki
echo "generate root cert"
vault write pki/root/generate/internal common_name=myvault.com ttl=87600h
echo "configure cert url"
vault write pki/config/urls issuing_certificates="http://vault.example.com:8200/v1/pki/ca" crl_distribution_points="http://vault.example.com:8200/v1/pki/crl"
echo "create a domain role"
vault write pki/roles/example-dot-com allowed_domains=example.com allow_subdomains=true max_ttl=72h
echo "issue certificate"
# vault write pki/issue/example-dot-com common_name=blah.example.com
vault write pki/issue/example-dot-com common_name=blah2.example.com -format=json | jq -r '.data.private_key' > pki.json
cat pki.json | jq -r ".issuing_ca" > ca.crt
cat pki.json | jq -r ".private_key" > priv.key
cat pki.json | jq -r ".certificate" > cert.cer
