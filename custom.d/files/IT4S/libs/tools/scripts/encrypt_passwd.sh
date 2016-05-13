#! /bin/bash
#execute as: ./encrypt_passws.sh 'ssid' 'password'
#important to use the apostrophe ' around them
ssid=$1
passwd=$2

cmd="wpa_passphrase \"$ssid\" \"$passwd\"| grep psk | tail -1 | sed s/=/' '/g | awk {'print \$2'} | tr -d '\n'"
#echo $cmd
#eval very important, otherwise the apostrophe won't be recognized
eval $cmd
