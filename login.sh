#!/bin/bash
if [[ $(date +%u) -lt 6 ]] ; then
 exit 0
elif [ "$(id $PAM_USER | grep -Eo '\badmin\b')" = "admin" ]; then
 exit 0
else
 exit 1
fi
