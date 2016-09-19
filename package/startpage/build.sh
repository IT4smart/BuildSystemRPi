#!/bin/bash

# Are we running as root?
if [ "$(id -u)" -ne "0" ] ; then
  echo "error: this script must be executed with root privileges!"
  exit 1
fi

# Check if ./functions.sh script exists
if [ ! -r "../../functions.sh" ] ; then
  echo "error: '../../functions.sh' required script not found!"
  exit 1
fi

# Load utility functions
. ../../functions.sh

# Introdruce settings
set -e
echo -n -e "\n#\n# StartPage Bootstrap Settings\n#\n"
set -x

# Config for chroot

if [ "${1}" = "armv7" ] ; then
    APT_SERVER=mirrordirector.raspbian.org
    DISTRIBUTION=raspbian
    RELEASE_ARCH=armhf
    RELEASE=jessie
    QEMU_BINARY=/usr/bin/qemu-arm-static
elif [ "${1}" = "i686" ] ; then
    APT_SERVER=ftp.de.debian.org
    DISTRIBUTION=debian
    RELEASE_ARCH=i386
    RELEASE=jessie
    QEMU_BINARY=/usr/bin/qemu-i386-static
else
    echo -e "The architecture ${1} is not supported"
    exit 1
fi

R=$(pwd)/build/chroot
SRC_DIR=/tmp

# Packages required for bootstrapping
REQUIRED_PACKAGES="debootstrap debian-archive-keyring qemu-user-static binfmt-support git"
MISSING_PACKAGES=""

set +x

# Check if all required packages are installed on the build system
for package in $REQUIRED_PACKAGES ; do
  if [ "`dpkg-query -W -f='${Status}' $package`" != "install ok installed" ] ; then
    MISSING_PACKAGES="${MISSING_PACKAGES} $package"
  fi
done

# Ask if missing packages should get installed right now
if [ -n "$MISSING_PACKAGES" ] ; then
  echo "the following packages needed by this script are not installed:"
  echo "$MISSING_PACKAGES"

  echo -n "\ndo you want to install the missing packages right now? [y/n] "
  read confirm
  [ "$confirm" != "y" ] && exit 1
fi

set -x

# Call "cleanup" function on various signals and errors
trap cleanup 0 1 2 3 6

function get_repo_key() {
mkdir -p "${R}"

REPOKEY=""
if [ "$DISTRIBUTION" = raspbian ] ; then
 REPOKEY="build/raspbianrepokey.gpg"
  if [ -f $REPOKEY ] ; then
  rm $REPOKEY
  fi
 wget -O - $APT_SERVER/raspbian.public.key | gpg --no-default-keyring --keyring $REPOKEY --import
 REPOKEY="--keyring ${REPOKEY}"
fi
}

function prepare_build_env() {  

    APT_INCLUDES=apt-transport-https,apt-utils,ca-certificates,dialog,sudo,git,build-essential,bc,qt5-default,cmake

    # Base debootstrap
    if [ "${1}" = "armv7" ] ; then
        APT_INCLUDES="${APT_INCLUDES},raspbian-archive-keyring"
        http_proxy=${APT_PROXY} debootstrap --arch="${RELEASE_ARCH}" $REPOKEY --foreign --include="${APT_INCLUDES}" "${RELEASE}" "${R}" "http://${APT_SERVER}/${DISTRIBUTION}"
    else
        http_proxy=${APT_PROXY} debootstrap --arch="${RELEASE_ARCH}" --foreign --include="${APT_INCLUDES}" "${RELEASE}" "${R}" "http://${APT_SERVER}/${DISTRIBUTION}"
    fi
    
    # Copy qemu emulator binary to chroot
    cp "${QEMU_BINARY}" "$R/usr/bin"

    # Copy debian-archive-keyring.pgp
    mkdir -p "$R/usr/share/keyrings"
    install_readonly /usr/share/keyrings/debian-archive-keyring.gpg "${R}/usr/share/keyrings/debian-archive-keyring.gpg"
    
    # Complete the bootstrapping process
    chroot_exec /debootstrap/debootstrap --second-stage
    
    # Mount required filesystems
    mount -t proc none "$R/proc"
    mount -t sysfs none "$R/sys"
    
    # Mount pseudo terminal slave if supported by Debian release
    #if [ -d "${R}/dev/pts" ] ; then
        mount --bind /dev/pts "${R}/dev/pts"
    #fi
}


#########
## MAIN 
#########
echo -e "Prepare environment"
sudo rm -rf "${R}" > /dev/null 2>&1
get_repo_key
prepare_build_env "${1}"

# print architecutre
chroot_exec dpkg --print-architecture

# old. later we make a pull request and merge the forked repo with the develop and alex branch
#git clone -b alex http://build.service:123456@devbase.it4s.eu:3000/IT4S/StartPage.git "${R}${SRC_DIR}"

# new forked repo for StartPage
git clone -b alex http://build.service:123456@devbase.it4s.eu:3000/raphael.lekies/StartPage.git "${R}${SRC_DIR}"

# build 
echo -e "Building IT4S - Startpage for $1"
chroot_exec make -C "${SRC_DIR}" "${1}"

# copy debian package from build directory to root
cp "${R}${SRC_DIR}/${1}-startpage.deb" $(pwd)

echo -e "Cleaning up"
cleanup
