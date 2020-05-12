#!/usr/bin/env bash
set -e

log(){ echo `date +%y%m%d_%H%M%S`" - $@"; }

{

    log "Starting..."
    # The `-gt 3` comes because there will be the `grep` and the script itself running. (the third thing is not completely clear...)
  autossh_running=`ps -Af | grep --count autossh`
  if [[ $autossh_running  -gt 3 ]]; then
    log "autossh is already working. Run 'pkill autossh' to rerun this script"
    exit
  fi
  
  autossh(){ /usr/local/bin/autossh -M 0 -f -N "$@" & }


  autossh t-omg-prd-http    
  autossh t-omg-dev-http
  autossh t-omg-ikube-http
  # autossh t-omg-int    # The vCenter is shared with prd
  
  autossh t-omg-prd-socks5
  autossh t-scs-prd-socks5

  log "All done!"

} 2>> /tmp/autossh.bash  1>&2

