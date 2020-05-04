#!/usr/bin/env bash

# Server specific consul configuration grabbing local IP
sudo tee /etc/vault-ssh-helper.d/config.hcl <<EOF
vault_addr = "http://${vault_address}:8200"
ssh_mount_point = "ssh"
ca_cert = "-dev"
tls_skip_verify = false
allowed_roles = "*"
EOF
