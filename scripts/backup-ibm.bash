#!/usr/bin/env bash


SSID=`networksetup -getairportnetwork en0 | awk '{print $(NF)}' || echo ""`
NLOG=3




export PATH="/Library/TeX/texbin:/usr/local/bin:/usr/local/bin:/Users/rpe/.dotfiles/bin:/usr/local/opt/coreutils/libexec/gnubin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/X11/bin:/Library/TeX/texbin"
export SHELL=/usr/local/bin/bash

n_log=`ls -1 /tmp/dsmc.log.* 2>/dev/null | wc -l`
while [[ "${n_log}" -lt "$NLOG" ]]; do
  touch /tmp/dsmc.log.${n_log}
  n_log=`ls -1 /tmp/dsmc.log.* 2>/dev/null | wc -l`
done

oldest=`ls -1t /tmp/dsmc.log.* | tail -1 `


if [[ "${SSID}" == "IBM" ]]; then
  dsmc incr -detail &>"$oldest"
fi
