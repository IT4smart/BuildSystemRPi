#! /bin/bash
echo -n `ip address |grep -A 1 ' wl.*: ' | grep link/ether | awk {'print $2'} | tr [:lower:] [:upper:] | tr -d '\n'`

