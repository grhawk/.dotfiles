#!/bin/bash

## Credits: http://unix.stackexchange.com/questions/53150/how-do-i-resize-the-active-window-to-50-with-wmctrl


# resizes the window to full height and 50% width and moves into upper right corner

#define the height in px of the top system-bar:
TOPMARGIN=0
BOTTOMMARGIN=42

#sum in px of all horizontal borders:
RIGHTMARGIN=0

# get width of screen and height of screen
SCREEN_WIDTH=$(xwininfo -root | awk '$1=="Width:" {print $2}')
SCREEN_HEIGHT=$(xwininfo -root | awk '$1=="Height:" {print $2}')


function move_windows_right {
  # new width and height
  W=$(( $SCREEN_WIDTH / 2 ))
  H=$(( $SCREEN_HEIGHT - $TOPMARGIN - $BOTTOMMARGIN ))
  
  # X, change to move left or right:
  
  # moving to the right half of the screen:
  X=$(( $SCREEN_WIDTH / 2 ))
  # moving to the left:
  #X=0;
  
  Y=$TOPMARGIN
  
  wmctrl -r :ACTIVE: -b remove,maximized_vert,maximized_horz && wmctrl -r :ACTIVE: -e 0,$X,$Y,$W,$H
}


function move_windows_left {
  # new width and height
  W=$(( $SCREEN_WIDTH / 2 ))
  H=$(( $SCREEN_HEIGHT - $TOPMARGIN -$BOTTOMMARGIN ))
  
  # X, change to move left or right:
  
  # moving to the left:
  X=0
  
  Y=$TOPMARGIN
  
  wmctrl -r :ACTIVE: -b remove,maximized_vert,maximized_horz && wmctrl -r :ACTIVE: -e 0,$X,$Y,$W,$H
}

function move_windows_up {
  # new width and height
  W=$(( $SCREEN_WIDTH ))
  H=$(( ($SCREEN_HEIGHT - $TOPMARGIN - $BOTTOMMARGIN) / 2 ))
  
  # X, change to move left or right:
  
  # moving to the left:
  X=0;
  
  Y=$TOPMARGIN
  
  wmctrl -r :ACTIVE: -b remove,maximized_vert,maximized_horz && wmctrl -r :ACTIVE: -e 0,$X,$Y,$W,$H
}


function move_windows_down {
  # new width and height
  W=$(( $SCREEN_WIDTH ))
  H=$(( ($SCREEN_HEIGHT - $TOPMARGIN - $BOTTOMMARGIN) / 2 ))
  
  # X, change to move left or right:
  
  # moving to the left:
  X=0;
  
  Y=$H

  
  wmctrl -r :ACTIVE: -b remove,maximized_vert,maximized_horz && wmctrl -r :ACTIVE: -e 0,$X,$Y,$W,$H
}


function windows_maximize {
  wmctrl -r :ACTIVE: -b add,maximized_vert,maximized_horz
}






move_windows_down
sleep 1
move_windows_left
sleep 1
move_windows_up
sleep 1
move_windows_right
sleep 1
move_windows_down
sleep 1
windows_maximize

