#Go development
export GOPATH="${HOME}/.go"
export GOROOT="`brew --prefix golang`/libexec"

[[ -d "${GOPATH}" ]] || mkdir ${GOPATH}
[[ -d "${GOPATH}/src/github.com" ]] || mkdir -p "${GOPATH}/src/github.com"

add_to_path ${GOPATH}/bin
add_to_path ${GOROOT}/bin

