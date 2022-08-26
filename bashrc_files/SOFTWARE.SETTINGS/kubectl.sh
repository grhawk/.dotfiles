#!/usr/bin/env bash

# kubectl autocompletion
source <(kubectl completion bash)

function kfake() {
  if ! kubectl "$@" --dry-run=client -oyaml 2> /tmp/kfake_output; then
    if grep 'Error: unknown flag: --dry-run' /tmp/kfake_output > /dev/null; then
      echo "Cannot fake this kubectl command! Use \`k\` instead of \`kfake\`"
    else
      cat /tmp/kfake_output >&2
    fi
  fi
}
complete -F __start_kubectl kfake

function kbash() {
  POD_NAME=$1
  kubectl exec -it "$POD_NAME" bash
}

function add-k8s-alias() {
  function usage(){
    echo "Usage: add-k8s-alias <ALIAS_NAME> [NAMESPACE]"
    echo "Create an alias to kubectl with completion enabled and, if specified"
    echo "pointing directly to a namespace."
  }
  
  ALIAS_NAME=$1
  NAMESPACE=$2

  if [[ -z $ALIAS_NAME ]]; then
    usage
    return
  fi

  if [[ -z $NAMESPACE ]]; then
    NAMESPACE_OPTION=""
  else
    NAMESPACE_OPTION="-n $NAMESPACE"
  fi
  
  alias "${ALIAS_NAME}=kubectl ${NAMESPACE_OPTION}"
  complete -F __start_kubectl "${ALIAS_NAME}"

}

# Default aliases
add-k8s-alias k
add-k8s-alias kube
add-k8s-alias ksys kube-system


