#!/usr/bin/env bash

#Go development
export GOPATH="${HOME}/.go"
GOROOT='/usr/local/opt/go/libexec'
if [[ -d "$GOROOT" ]]; then
    export GOROOT
else
    # echo 'WARNING: "GOROOT" not found!'
    # echo 'Looking for GOROOT with brew'
    export GOROOT="`brew --prefix golang`/libexec"
fi

[[ -d "${GOPATH}" ]] || mkdir ${GOPATH}
[[ -d "${GOPATH}/src/github.com" ]] || mkdir -p "${GOPATH}/src/github.com"

add_to_path ${GOPATH}/bin
add_to_path ${GOROOT}/bin

