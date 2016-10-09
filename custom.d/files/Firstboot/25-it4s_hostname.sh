logger -t "rc.firstboot" "set custom it4s hostname"

# add function to change hostname
newname=IT4S$(printf '%s' $(cat /sys/class/net/eth0/address) | md5sum | cut -c 1-8)
sudo sh -c "printf %s $newname >/etc/hostname"
sudo sh -c "sed 's/rpi2-jessie/'$newname'/g' /etc/hosts >/etc/hosts.test"
sudo mv /etc/hosts.test /etc/hosts
