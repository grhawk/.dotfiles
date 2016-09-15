#!/bin/bash


#nmap 128.178.55.217 -PN -p ssh | grep open > /dev/null && (bash -c "unison Documents" && kdialog --passivepopup "Documents Synchronized" 5 || kdialog --passivepopup "There is some problems!" 5 ) || kdialog --passivepopup "Your computer is unreacheble!" 5

nmap 128.178.55.217 -PN -p ssh | grep open > /dev/null && (bash -c "unison Documents" && kdialog --passivepopup "Documents Synchronized" 5 || kdialog --passivepopup "There is some problems!" 5 ) || kdialog --passivepopup "Your computer is unreacheble!" 5

