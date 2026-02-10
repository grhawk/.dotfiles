#!/usr/bin/env sh

set -x

## super-ssh configuration
export SUPER_SSH_TMUX_CONF="${HOME}/.dotfiles/tmux.conf"
export SUPER_SSH_SESSION_MODE="per-host"

alias ssh="\${HOME}/.dotfiles/super-ssh/super-ssh"

source "${HOME}/.dotfiles/super-ssh/completions/super-ssh.bash"

set +x
