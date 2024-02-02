#!/usr/bin/env bash

RESOURCE_FOLDER="${HOME}/.dotfiles/bashrc_files/SOFTWARE.SETTINGS/resources"

if [[ ! -f "${RESOURCE_FOLDER}/vagrant-bash-completion.sh" ]]; then
  wget https://raw.githubusercontent.com/hashicorp/vagrant/master/contrib/bash/completion.sh -O "${RESOURCE_FOLDER}/vagrant-bash-completion.sh"
fi

# shellcheck source=/dev/null
source "${RESOURCE_FOLDER}/vagrant-bash-completion.sh"