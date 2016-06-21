#!/usr/bin/env bash

# Try to using independent names. The variable "$Codes" and
# "$Projects" should be exported from the bashrc.


# The following find the first parent directory that contains the .git
# folder and that is 1 level deeper than the MyProjects or MyCodes
# directory.

PROJECTS=$HOME/MyProjects
CODES=$HOME/MyCodes

function find_git {
  local DIR=$1
  ls $DIR/.git &> /dev/null
  while [[ $? -ne 0 ]]; do
    TMP=`echo $DIR | rev | cut -d'/' -f2- | rev`
    DIR=$TMP
    ls $DIR/.git &> /dev/null
    if [[ -z "$DIR" ]]; then
      exit 101
    fi
  done
  echo $DIR
}

function is_root {
  local DIR=$1
  local parent=`echo $DIR | rev | cut -d'/' -f2- | rev`
  if [[ "$parent" == "$PROJECTS" ]]; then
    return 0
  elif [[ "$parent" == "$CODES" ]]; then
    return 0
  else
    return 2
  fi
}


DIR_IN=`tmux display-message -p -F "#{pane_current_path}" -t0`
TMP=`find_git $DIR_IN`
DIR_IN=$TMP
while ! is_root $DIR_IN; do
  TMP=`echo $DIR_IN | rev | cut -d'/' -f2- | rev`
  DIR_IN=$TMP
  TMP=`find_git $DIR_IN`
  DIR_IN=$TMP
  if [[ -z "$DIR_IN" ]]; then
    exit 101
  fi
done

tmux split-window -h "emacsclient -nw $DIR_IN/README.org"
