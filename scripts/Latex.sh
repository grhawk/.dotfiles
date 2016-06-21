#!/bin/bash

source ~/.bash_aliases



PROJPATH=`kdialog --getexistingdirectory $HOME/Documents`
echo $PROJPATH
if [[ -z $PROJPATH ]] || [[ "$PROJPATH" == "$HOME" ]]; then
  exit
fi

if [[ ! -f $PROJPATH/.project_metadata ]] && [ ! "$(ls -A $PROJPATH)" ]; then 
  PROJTITLE=`kdialog --inputbox "Select a name for the new project:"`
  
  ## Generate a Title
  if [[ -z "$PROJTITLE" ]]; then
    sure=`kdialog --warningyesno "Do you want to remove the directory<br>$PROJPATH?"`
    if [[ "$?" -eq 0 ]]; then
      rmdir $PROJPATH
      if [[ "$?" -ne 0 ]]; then
	kdialog --msgbox "$PROJPATH is not empty<br>Remove it by hand" 5
      fi
      exit
    else
      exit
    fi
    exit
  fi

  ## Define a Template to use
  i=0
  for a in $HOME/Store/Latex_Templates/*; do
    let i+=1
    echo " $i \"${a/$HOME\/Store\/Latex_Templates\//}\"" >> $PROJPATH/.template_menu
    template_menu+=" $i \"${a/$HOME\/Store\/Latex_Templates\//}\""
  done
  TEMPLATE=`kdialog --menu "Choose a template:" $(cat $PROJPATH/.template_menu)`
  if [[ -z $TEMPLATE ]]; then
    sure=`kdialog --warningyesno "Do you want to remove the directory<br>$PROJPATH?"`
    if [[ "$?" -eq 0 ]]; then
      rm -f $PROJPATH/.template_menu 
      rmdir $PROJPATH
      if [[ "$?" -ne 0 ]]; then
	kdialog --msgbox "$PROJPATH is not empty<br>Remove it by hand" 5
      fi
      exit
    else
      exit
    fi
    exit
  fi
  
  TEMPLATE_NAME=`awk -v template=$TEMPLATE '{if($1 == template){print $2}}' $PROJPATH/.template_menu`
  TEMPLATE_NAME=${TEMPLATE_NAME//\"/}
  
  ## Write the metadata file
  cat <<EOF > $PROJPATH/.project_metadata
PROJPATH:        $PROJPATH
PROJTITLE:       $PROJTITLE
TEMPLATE_MENU:   $template_menu
TEMPLATE:        $TEMPLATE
TEMPLATE_NAME:   $TEMPLATE_NAME
EOF

  ## Initialize the directory
  cp -r $HOME/Store/Latex_Templates/$TEMPLATE_NAME/* $PROJPATH
  cp $HOME/Store/Latex_Templates/.commonfiles/.gitignore $PROJPATH
  cp $HOME/Store/Latex_Templates/.commonfiles/exit $PROJPATH

  cd $PROJPATH; 
  sed -e s/pippoplutotitle/$PROJTITLE/g exit > asd; rm -f exit; mv asd exit
  tmp=$(echo $PROJPATH  | sed -e s/'\/'/'\\\/'/g)
  echo $tmp
  sed -e s/pippoplutopath/$tmp/g Makefile > asd; rm -f Makefile; mv asd Makefile
  git init
  git add .
  git commit -m 'Template Revision'
  make > /dev/null
  chmod 755 exit
  cd -

elif [[ -f $PROJPATH/.project_metadata ]]; then

  PROJTITLE=`awk '{if($1 == "PROJTITLE:"){print $2}}' $PROJPATH/.project_metadata`
  

else
  
  kdialog --msgbox "The directory is not empty and it is not a Latex project!" 5
  exit
fi

addDesktop
desktop=`getDesktopId`
okular --caption "$PROJTITLE - okular" $PROJPATH/Main.pdf &
terminator -T "$PROJTITLE - shell support" --working-dir=$PROJPATH &
emacs -T "$PROJTITLE - emacs" $PROJPATH/tex &
sleep 1

emacs=`getWindowId emacs`
terminator=`getWindowId "shell support"`
okular=`getWindowId okular`
cat <<EOF > "/tmp/${PROJTITLE}_Windows_control.tmp"
d$desktop
$emacs
$okular
$terminator
EOF

sleep 2

wmctrl -i -r $emacs -e 1,0,0,800,850 &
(wmctrl -i -r $terminator -e 1,800,737,800,120
 wmctrl -i -r $terminator -b add,above ) &
(wmctrl -i -r $okular -b remove,maximized_vert,maximized_horz
 wmctrl -i -r $okular -e 1,804,0,796,716 )&

