#
# First boot actions
#

# Load utility functions
. ./functions.sh

# Prepare rc.firstboot script
cat files/firstboot/10-begin.sh > "$R/etc/rc.firstboot"

# Ensure openssh server host keys are regenerated on first boot
if [ "$ENABLE_SSHD" = true ] ; then
  cat files/firstboot/21-generate-ssh-keys.sh >> "$R/etc/rc.firstboot"
  rm -f "$R/etc/ssh/ssh_host_*"
fi

# Prepare filesystem auto expand
if [ "$EXPANDROOT" = true ] ; then
  cat files/firstboot/22-expandroot.sh >> "$R/etc/rc.firstboot"
fi

# Ensure that dbus machine-id exists
cat files/firstboot/23-generate-machineid.sh >> "$R/etc/rc.firstboot"

# Create /etc/resolv.conf symlink
cat files/firstboot/24-create-resolv-symlink.sh >> "$R/etc/rc.firstboot"

if [ "$ENABLE_THINCLIENT" = true ] ; then
  # Change hostname
  cat custom.d/files/Firstboot/25-it4s_hostname.sh >> "$R/etc/rc.firstboot"

  # Change permission
  cat custom.d/files/Firstboot/26-change_permissions.sh >> "$R/etc/rc.firstboot"
fi

# Finalize rc.firstboot script
cat files/firstboot/99-finish.sh >> "$R/etc/rc.firstboot"
chmod +x "$R/etc/rc.firstboot"

# Add rc.firstboot script to rc.local
if [ ! -f "${ETC_DIR}/rc.local" ] ; then
  install_readonly files/etc/rc.local "$R/etc/rc.local"
  chroot_exec chmod +x /etc/rc.local
fi
sed -i '/exit 0/d' "$R/etc/rc.local"
echo /etc/rc.firstboot >> "$R/etc/rc.local"
echo exit 0 >> "$R/etc/rc.local"
