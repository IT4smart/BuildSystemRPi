#
# Citrix
#

# Load utility functions
. ./functions.sh

# install required packages, icaclient and ctxusb for usb passthrough support
if [ "$ENABLE_CITRIX" = true ] ; then
  APT_INCLUDES="${APT_INCLUDES} libxerces-c3.1 haveged libproxy-tools curl libwebkitgtk-1.0-0 icaclient=13.3.0.344519 ctxusb=2.6.344519"
  chroot_exec apt-get -qq -y install ${APT_INCLUDES}

  # accept license
  chroot_exec mkdir /home/pi/.ICAClient
  chroot_exec touch /home/pi/.ICAClient/.eula_accepted
fi

# certificate management
if [ "$ENABLE_CITRIX" = true ] ; then
  # copy all certificates from citrix keystore to /etc/ssl/certs
  chroot_exec cp -r /opt/Citrix/ICAClient/keystore/cacerts/ /etc/ssl/certs

  # remove old certificate folder from citrix
  chroot_exec rm -R /opt/Citrix/ICAClient/keystore/cacerts

  # create symbolic link
  chroot_exec ln -s /etc/ssl/certs /opt/Citrix/ICAClient/keystore/cacerts
fi

# custom certificates from customer.
if [ "$ENABLE_CITRIX_CUSTOM_CERT" = true ] ; then
  # copy custom certificates
  cp custom.d/files/Certificates/*.pem "$R/etc/ssl/certs/"
fi

# rehash all certificates
if [ "$ENABLE_CITRIX" = true ] ; then
  chroot_exec c_rehash /opt/Citrix/ICAClient/keystore/cacerts
fi
