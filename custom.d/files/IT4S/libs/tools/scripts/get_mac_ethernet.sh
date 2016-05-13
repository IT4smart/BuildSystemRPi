#! /bin/bash
echo -n `ip address |grep -A 1 ' e[a-zA-Z0-9]*: ' | grep link/ether | awk {'print $2'} | tr [:lower:] [:upper:] | tr -d '\n'`

