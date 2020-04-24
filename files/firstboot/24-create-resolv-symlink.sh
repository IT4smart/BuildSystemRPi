logger -t "rc.firstboot" "Creating /etc/resolv.conf symlink"

# Check if systemd resolve directory exists
if [ ! -d "/run/systemd/resolve" -a ! -e "/etc/resolv.conf" ] ; then
  systemctl enable systemd-resolved.service
  systemctl restart systemd-resolved.service
fi

# Create resolv.conf file if it does exists
if [ -f "/run/systemd/resolve/resolv.conf" ] ; then
  touch /run/systemd/resolve/resolv.conf
fi

# create symlink to /etc/resolv.conf if not exists
if [ ! -e "/etc/resolv.conf" ] ; then
  ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf
fi
