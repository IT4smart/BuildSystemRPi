#
# Install all Packages
#

# set default raspberry pi packages
APT_INCLUDES="${APT_INCLUDES} libraspberrypi0 flash-kernel"
#APT_INCLUDES="${APT_INCLUDES} libraspberrypi0 lsb-release"


chroot_exec apt-get -qq -y --no-install-recommends install ${APT_INCLUDES}
