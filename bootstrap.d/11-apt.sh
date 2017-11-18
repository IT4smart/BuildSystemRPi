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

if [ "${DISTRIBUTION}" = "raspbian" ] ; then
	install_readonly files/apt/raspi.list "$R/etc/apt/sources.list.d/raspi.list"
	chroot_exec wget http://archive.raspberrypi.org/debian/raspberrypi.gpg.key
	chroot_exec apt-key add raspberrypi.gpg.key
	chroot_exec rm raspberrypi.gpg.key
fi

# Install IT4Smart package repository
#install_readonly files/apt/it4smart.list "$R/etc/apt/sources.list.d/it4smart.list"
#sed -i "s/ jessie/ ${RELEASE}/" "$R/etc/apt/sources.list.d/it4smart.list"

#chroot_exec wget http://mirror.it4s.eu/mirror.it4s.eu.gpg.key
#chroot_exec apt-key add mirror.it4s.eu.gpg.key
#chroot_exec rm mirror.it4s.eu.gpg.key

# Upgrade package index and update all installed packages and changed dependencies
chroot_exec apt-get -qq -y update
chroot_exec apt-get -qq -y -u dist-upgrade
chroot_exec apt-get -qq -y check
