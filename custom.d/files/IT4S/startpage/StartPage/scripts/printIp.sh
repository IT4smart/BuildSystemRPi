#!/bin/bash
#IP=$(/sbin/ip route get 8.8.8.8 2>/dev/null | awk 'NR==1 {print $NF}' | tr -d '\n')
IP=$(/sbin/ip -4 -o addr show dev eth0| awk '{split($4,a,"/");print a[1]}')
echo -n $IP
