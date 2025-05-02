#!/usr/bin/env sh

export HOME=/Users/rpetraglia

pgrep -i moom && exit 1

case $1 in
    "docking_at_home")
        echo "Docking at home"
        defaults export com.manytricks.Moom ~/.dotfiles/moom-config/moom-laptop.plist
        defaults import com.manytricks.Moom ~/.dotfiles/moom-config/moom-home.plist
        ;;
    "un-docking_at_home")
        echo "Un-docking at home"
        defaults export com.manytricks.Moom ~/.dotfiles/moom-config/moom-home.plist
        defaults import com.manytricks.Moom ~/.dotfiles/moom-config/moom-laptop.plist
        ;;
    *)
        echo "Nothing to do with this arg"
        exit 1
        ;;
esac

open -a "Moom"
