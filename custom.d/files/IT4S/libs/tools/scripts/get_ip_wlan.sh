#! /bin/bash
echo -n `ip address |grep -A 2 ' wl.*: ' | grep inet | sed 's/\\// /g' | awk {'print $2'}| tr -d '\n'`
