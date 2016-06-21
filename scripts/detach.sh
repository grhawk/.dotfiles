#!/bin/bash


dev=`echo $1 | sed -e s/[0-9]//g`

udisks --detach $dev &> /tmp/detach.log
err=$?

if [[ "$err" == "0" ]]; then
    kdialog --passivepopup "$dev detached" 2
else
    kdialog --passivepopup "ERROR: detaching $dev\nLook in /tmp/detach.log" 3
fi    