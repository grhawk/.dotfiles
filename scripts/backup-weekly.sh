#!/bin/bash

rsync  -acvzPl --progress --delete --exclude=.gvfs/ --exclude=.config/google-chrome/ --exclude=.cache/ --exclude=.mozilla/ -e ssh /home/petragli/ petragli@128.178.43.54:/share/store/users/petragli/WEEKLY-BACKUP &> /tmp/backup_weekly_store.log

if [[ $? -ne 0 ]]; then
	cp /tmp/backup_weekly_store.log ~/weekly-backup.log
	kdialog --title "Weekly Backup Error" --error "Weekly backup have crashed.\nSee ~/weekly-backup.log for details."
	exit
fi

