#
# Set packages for kernel modules
#

if [ "$ENABLE_VCHIQ" = true ] ; then
  APT_INCLUDES="${APT_INCLUDES} libraspberrypi0"
fi
