#
# Setup APT repositories
#

# Load utility functions
. ./functions.sh

# Install and setup APT proxy configuration
if [ -z "$APT_PROXY" ] ; then
  install_readonly files/apt/10proxy "$R/etc/apt/apt.conf.d/10proxy"
  sed -i "s/\"\"/\"${APT_PROXY}\"/" "$R/etc/apt/apt.conf.d/10proxy"
fi

# Install APT pinning configuration for flash-kernel package
install_readonly files/apt/flash-kernel "$R/etc/apt/preferences.d/flash-kernel"

# Upgrade collabora package index and install collabora keyring
#echo "deb https://repositories.collabora.co.uk/debian ${RELEASE} rpi2" > "$R/etc/apt/sources.list"
#chroot_exec apt-get -qq -y update
#chroot_exec apt-get -qq -y --force-yes install collabora-obs-archive-keyring

# Install APT sources.list
install_readonly files/apt/sources.list "$R/etc/apt/sources.list"
sed -i "s/\/archive.raspbian.org\//\/${APT_SERVER}\//" "$R/etc/apt/sources.list"
sed -i "s/ raspbian/ ${DISTRIBUTION}/" "$R/etc/apt/sources.list"
sed -i "s/ jessie/ ${RELEASE}/" "$R/etc/apt/sources.list"

# found on raspbian from the foundation.
if [ "${DISTRIBUTION}" = "raspbian" ] ; then
    echo "deb http://archive.raspberrypi.org/debian/ jessie main ui" > "$R/etc/apt/sources.list.d/raspi.list"
    chroot_exec wget -O /tmp/raspberrypi.gpg.key https://archive.raspberrypi.org/debian/raspberrypi.gpg.key
    chroot_exec apt-key add /tmp/raspberrypi.gpg.key
fi

# Upgrade package index and update all installed packages and changed dependencies
chroot_exec apt-get -qq -y update
chroot_exec apt-get -qq -y -u dist-upgrade
chroot_exec apt-get -qq -y check
