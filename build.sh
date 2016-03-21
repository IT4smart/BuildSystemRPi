#!/bin/sh

#################################################
# Define all Variables for customization
#
#################################################

# Are we running as root?
if [ "$(id -u)" -ne "0" ] ; then
  echo "error: this script must be executed with root privileges!"
  exit 1
fi

# clean build before
rm -rf ./images

# Logging?
export BUILD_LOG=true

# set customization options
export DEFLOCAL="de_DE.UTF-8"
export XKB_LAYOUT="de"
export ENABLE_IPV6=false
export ENABLE_CONSOLE=false
export ENABLE_SPLASH=false
export ENABLE_WM="xfce4"
export APT_SERVER=mirrordirector.raspbian.org
export DISTRIBUTION=raspbian

# set debootstrap flag for raspbianrepokey if raspbian
export REPOKEY=""
if [ "$DISTRIBUTION" = raspbian ] ; then
 REPOKEY="files/apt/raspbianrepokey.gpg"
  if [ -f $REPOKEY ] ; then
  rm $REPOKEY
  fi
 wget -O - $APT_SERVER/raspbian.public.key | gpg --no-default-keyring --keyring $REPOKEY --import
 export REPOKEY="--keyring ${REPOKEY}"
fi

if [ "$BUILD_LOG" = true ] ; then
  script -c './rpi2-gen-image.sh' ./build.log
else
  ./rpi2-gen-image.sh
fi
