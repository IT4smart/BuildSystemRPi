#
# Custom ubiquiti installation
#
# Jessie: unifi 5.6.39
if [ "${ENABLE_UBNT}" = true ] ; then
  APT_INCLUDES="base-files-controller-it4smart avahi-daemon"
  chroot_exec apt-get -qq -y install ${APT_INCLUDES}
fi

if [ "${ENABLE_UBNT}" = true ] ; then
  # Remove old docker versions
  APT_INCLUDES="docker docker-engine docker.io"
  chroot_exec apt-get -qq -y remove ${APT_INCLUDES}

  if [ ${RELEASE} = "buster" ] ; then
    APT_INCLUDES="unifi-controller-it4smart=1.2.1~deb10"
  fi

  if [ ${RELEASE} = "jessie" ] || [ ${RELEASE} = "stretch" ] ; then
    APT_INCLUDES="unifi-controller-it4smart"
  fi
  APT_INCLUDES="apt-transport-https ca-certificates curl gnupg2 software-properties-common docker-ce ${APT_INCLUDES}"
  chroot_exec apt-get -qq -y install ${APT_INCLUDES}

  # Set message for users to know which ip the device has
  chroot_exec echo "Ubiquiti Controller: https://\\4:8443" >> "$R/etc/issue"

  chroot_exec systemctl enable unifi.service
fi
