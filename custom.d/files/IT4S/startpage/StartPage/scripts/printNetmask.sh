#!/bin/bash
DEFAULT_IF=$(ip route list | awk '/^default/ {print $5}')
NETMASK=$(/sbin/ifconfig $DEFAULT_IF 2>/dev/null | awk '/inet Adresse:/ {print $4}' | sed 's/Maske://')
echo -n $NETMASK

