#!/bin/bash

# Show network statistics for all active interfaces found.

run_segment() {
  mem=$(free -k 2>/dev/null)
  if [ "$?" -ne 0 ]; then
    echo "###"
	return 1
  fi

  totram=$(echo "$mem" | grep "Mem" | awk '{print $2}')
  totswap=$(echo "$mem" | grep "Swap:" | awk '{print $2}')
  usedram=$(echo "$mem" | grep "Mem:" |awk '{print $3}')
  usedswap=$(echo "$mem" | grep "Swap:" |awk '{print $3}')

  echo "${usedram} ${totram} ${usedswap} ${totswap}" | awk '{printf"R:%2.1f%% S:%2.1f%%",$1/$2*100,$3/$4*100}'


  return 0
}


run_segment
