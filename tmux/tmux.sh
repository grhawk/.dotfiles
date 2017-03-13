#!/bin/bash

HOME_WIN=""

SESSIONS=$(tmux ls -F '#{session_id}; #{session_name}; #{session_windows};\n')

for ses in $(echo -e $SESSIONS | awk -F';' '{printf" %s", $2}'); do
  if [[ $ses == "HOME" ]]; then
    WINDOWS=$(tmux lsw -F '#{window_id}; #{window_name}\n' -t $ses)
    for win in $(echo -e $WINDOWS | awk -F';' '{printf" %s", $2}'); do
      if [[ $win == "Home" ]]; then
        HOME_WIN="${ses}:${win}"
      fi
    done
  fi
done


if [[ -z "$HOME_WIN" ]]; then
  echo "START A NEW HOME SESSION"
else
  echo "HOME: $HOME_WIN"
fi
