#------------------#
# wmctrl Functions #
#------------------#

function addDesktop() {
    desknum=`wmctrl -d | wc -l `
    let desknum+=1
    wmctrl -n $desknum
    let desknum-=1
    wmctrl -s $desknum
}

function remDesktop() {
    ARG=$1
    desktot=`wmctrl -d | wc -l`
    deskrm=${ARG:-$desktot}
    let deskrm-=1
    
    let finaldesknum=desktot-1
    let desktot-=1
    
    for((d=$deskrm;d<=$desktot;d++)); do
	let tod=$d-1
	wmctrl -l | 
	while read wind; do
	    mvwind=`echo $wind | awk -v desk=$d '{if($2 == desk){print $1}}'`
	    if [[ -n $mvwind ]]; then
		wmctrl -i -r $mvwind -t $tod
	    fi
	done
    done
    wmctrl -n $finaldesknum
}

function getWindowId() {
    wmctrl -l | grep "$1" | tail -1 | cut -f1 -d" "
}

function getDesktopId() {
    desk=`wmctrl -d | grep '*' | cut -f1 -d' '`
    let desk+=1
    echo $desk
}

function restoreDesktops() {
    nowdesk=`wmctrl -d | grep '*' | cut -f1 -d" "`
    [[ $nowdesk -gt 2 ]] && nowdesk=2

    desknum=`wmctrl -d | wc -l `
    while [[ $desknum -gt 3 ]]; do
	remDesktop
	desknum=`wmctrl -d | wc -l `
    done
    wmctrl -s $nowdesk
}
