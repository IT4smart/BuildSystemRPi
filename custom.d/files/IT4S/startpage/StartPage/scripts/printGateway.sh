#!/bin/bash
GW=$(/sbin/ip route 2>/dev/null | awk '/default/ { print $3 }')
echo -n $GW
