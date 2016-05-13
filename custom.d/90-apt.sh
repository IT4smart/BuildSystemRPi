#
# Install all Packages
#

# set default raspberry pi packages
APT_INCLUDES="${APT_INCLUDES} libraspberrypi0 flash-kernel"

chroot_exec apt-get -qq -y install ${APT_INCLUDES}
