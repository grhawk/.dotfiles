#!/usr/bin/env sh

NOMAD_ADDR="https://nomad.meteomatics.com:4646"
NOMAD_TOKEN=$(cat ${HOME}/.nomad/token)
NOMAD_NAMESPACE="*"
NOMAD_TLS_SERVER_NAME="server.global.nomad"
NOMAD_CACERT=${HOME}/.nomad/nomad_cacert.pem
NOMAD_CLIENT_CERT=${HOME}/.nomad/global-cli-nomad-6-rpetraglia.pem
NOMAD_CLIENT_KEY=${HOME}/.nomad/global-cli-nomad-key-6-rpetraglia.pem



export NOMAD_ADDR
export NOMAD_TOKEN
export NOMAD_NAMESPACE
export NOMAD_TLS_SERVER_NAME
export NOMAD_CACERT
export NOMAD_CLIENT_CERT
export NOMAD_CLIENT_KEY
