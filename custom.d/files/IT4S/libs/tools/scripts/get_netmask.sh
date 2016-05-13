#! /bin/bash
echo -n `ip address |grep -A 2 ' e[a-zA-Z0-9]*0: '| grep inet | sed 's/\\// /g' | awk {'print $3'}| tr -d '\n'`
