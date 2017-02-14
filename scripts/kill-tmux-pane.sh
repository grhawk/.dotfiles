#!/usr/bin/env bash

# Get the number of tmux windows
WIN=`tmux list-windows | wc -l`

# Get the number of tmux panes in the current window
PANES=`tmux list-panes | wc -l`

TOTAL=$(($PANES*$WIN))

if [[ $PANES -lt 2 ]]; then
  tmux display-message "Cannot close last pane!"
else
  ACTIVE_PANE=`tmux list-panes | grep active | awk -F':' '{print $1}'`
  tmux kill-pane -t $ACTIVE_PANE
fi
