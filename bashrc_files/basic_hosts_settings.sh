#!/usr/bin/env bash


case $1 in
    'Olgas-Air')
	    export PS1_COLOR
        PS1_COLOR="$(tput setaf 219)"
	    ;;
    'UM01175')
    	export PS1_COLOR
        PS1_COLOR="$(tput setaf 247)"
    	;;
    *)
	    ;;
esac
