#!/bin/bash

(urxvtd -q -f -o &>> /tmp/run_at_startup.log)&                # urxvt server daemon to connect to with clients
(xbindkeys -n -f .xbindkeysrc &>> /tmp/run_at_startup.log)&   # xbindkey as a daemon to get the keybind ;)
(tmux -2 new-session -n$USER -s $USER@$HOSTNAME -d -c "$HOME/" &>> /tmp/run_at_startup.log )& # Start tmux server
(sleep 15; emacs -daemon &>> /tmp/run_at_startup.log)&		       # emacs will start much much faster
(cd ~/.dotfiles/software/; ./rslsync ; cd -)& # Sync with raspberry
