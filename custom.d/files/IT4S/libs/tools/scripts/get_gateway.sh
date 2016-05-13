#! /bin/bash
echo -n `ip route | grep default | head -1 | awk {'print $3'} |tr -d '\n'`
