#!/bin/bash

sudo -u root mkdir /mnt/TEMP && \
sudo -u root mount -t cifs //192.168.1.100/RBakcup /mnt/TEMP || exit 2

rsync  -acvzPl --progress --delete --exclude-list=/home/riccardo/.dotfiles/rsync-excludelist /home/riccardo/ /mnt/TEMP/DAILY-BACKUP &> /tmp/backup_daily_store.log

if [[ $? -ne 0 ]]; then
	cp /tmp/backup_daily_store.log ~/daily-backup.log
	kdialog --title "Daily Backup Error" --error "Daily backup have crashed.\nSee ~/daily-backup.log for details."
	exit
fi
