#!/bin/bash

(urxvtd -q -f -o)&                # urxvt server daemon to connect to with clients
(xbindkeys -n -f .xbindkeysrc)&   # xbindkey as a daemon to get the keybind ;)
(tmux -2 new-session -n$USER -s $USER@$HOSTNAME -d -c "$HOME/")& # Start tmux server
(sleep 5; emacs -daemon)&		       # emacs will start much much faster
(cd ~/.dotfiles/software/; ./rslsync; cd -)& # Sync with raspberry
