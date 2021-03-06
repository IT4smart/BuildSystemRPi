#!/bin/sh

# commandline arguments
arch=$1
project=$2
release=$3

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
export RELEASE=${release}

# General settings
export IT4SMART_VERSION=1.0.0

# check the architecture
if [ ${arch} = "rpi2" ]; then
    # set customization options
    export DEFLOCAL="de_DE.UTF-8"
    export XKB_LAYOUT="de"
    export ENABLE_IPV6=false
    export ENABLE_CONSOLE=false
    export ENABLE_SPLASH=true
    export ENABLE_VCHIQ=true
    export APT_SERVER=mirrordirector.raspbian.org
    export DISTRIBUTION=raspbian
    export ENABLE_BOOTSPLASH=true
    export COLLABORA_KERNEL=rpi2-rpfv

    # select the customization option for the specific project
    if [ ${project} = "ass" ]; then
        export ENABLE_WM="xfce4"
        export ENABLE_CITRIX=true
        export ENABLE_AUTOMOUNT=true
        export ENABLE_THINCLIENT=true
        #export NET_NTP_1=172.16.0.1
        export ENABLE_CITRIX_CUSTOM_CERT=true
    fi

    if [ ${project} = "ubnt" ]; then
      export ENABLE_UBNT=true
      export HOSTNAME="ubnt-it4smart"
    fi

    if [ "${release}" = "buster" ]; then
      APT_INCLUDES="systemd"
    fi
fi

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
