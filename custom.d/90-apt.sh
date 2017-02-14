#
# Install all Packages
#

# set default raspberry pi packages
#APT_INCLUDES="libraspberrypi0 flash-kernel"
APT_INCLUDES="libraspberrypi0"

# see all hold packages
chroot_exec apt-mark showhold 

chroot_exec apt-get -qq -y install ${APT_INCLUDES}
