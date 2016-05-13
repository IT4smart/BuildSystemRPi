#! /bin/bash
echo -n `cat /etc/resolv.conf | grep nameserver | awk {'print $2";"'} |tr -d '\n'`
