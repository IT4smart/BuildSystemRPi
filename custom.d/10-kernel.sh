#
# Set packages for kernel modules and booting
#

# Load utility functions
. ./functions.sh

# Disable rainbow splash
if [ "$ENABLE_SPLASH" = false ] ; then
  sed -i "s/^#disable_splash=1/disable_splash=1/" "$R/boot/config.txt"
fi