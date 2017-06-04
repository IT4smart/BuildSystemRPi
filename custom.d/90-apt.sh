#
# Install all Packages
#

# set default raspberry pi packages
<<<<<<< HEAD
#APT_INCLUDES="libraspberrypi0 flash-kernel"
APT_INCLUDES="libraspberrypi0"

# see all hold packages
chroot_exec apt-mark showhold 
=======
#APT_INCLUDES="${APT_INCLUDES} libraspberrypi0 flash-kernel"
APT_INCLUDES="${APT_INCLUDES} libraspberrypi0 lsb-release"

>>>>>>> 0cdb28c1c161e1be791abd18d10effd4bd336443

chroot_exec apt-get -qq -y install ${APT_INCLUDES}
