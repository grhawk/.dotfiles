#!/usr/bin/env bash

# Check the answer
if [[ -n $1 ]]; then
  echo $1 | grep -i "y" &>> /dev/null  || MSG="User's choice"
else
  MSG=''
fi

# Get the number of tmux windows
WIN=`tmux list-windows | wc -l`

if [[ $WIN -lt 2 ]]; then
  MSG="Cannot close last window!"
elif [[ -z $MSG ]]; then
  ACTIVE_WINDOW=`tmux list-windows | grep active | awk -F':' '{print $1}'`
  tmux kill-window -t $ACTIVE_WINDOW
fi

if [[ -z $MSG ]]; then
  tmux display-message "$MSG"
fi
