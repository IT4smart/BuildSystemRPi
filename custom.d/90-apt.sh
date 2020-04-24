#
# Install all Packages
#

# set default raspberry pi packages
if [ "${RELEASE}" = "buster" ] | [ "${RELEASE}" = "stretch" ]; then
  APT_INCLUDES="libraspberrypi0 libraspberrypi-bin"
else
  APT_INCLUDES="libraspberrypi0 flash-kernel"
fi

APT_INCLUDES="${APT_INCLUDES} lsb-release"
#APT_INCLUDES="${APT_INCLUDES} libraspberrypi0 lsb-release"


chroot_exec apt-get -qq -y --no-install-recommends install ${APT_INCLUDES}

# Remove resolv.conf
if [ "${RELEASE}" = "buster" ] | [ "${RELEASE}" = "stretch" ] ; then
  chroot_exec rm /etc/resolv.conf
fi
