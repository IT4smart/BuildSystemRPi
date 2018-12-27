logger -t "rc.firstboot" "First boot actions finished"
rm -f /etc/rc.firstboot
sudo reboot
sed -i '/.*rc.firstboot/d' /etc/rc.local
