#!/usr/bin/env bash

DEVICES=`xsetwacom --list devices | head -2 | awk '{printf "%i ", $7}' `

# Rotate to avoid wires mess
for dev in $DEVICES; do
  echo "Rotating $dev..."
  xsetwacom --set $dev Rotate half
done

# Set only on the VGA screen if active.
if xrandr | awk '/VGA-1/{if($2 == "connected"){exit 0}else{exit 1}}'; then
  for dev in $DEVICES; do
    echo "Fixing the screen for $dev..."
    xsetwacom --set $dev MapToOutput "VGA-1"
  done
fi
