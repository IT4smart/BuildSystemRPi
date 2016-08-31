#!/bin/bash

# Load utility functions
. ../../functions.sh

# Config for chroot

if [ "${1}" = armv7 ] ; then
    APT_SERVER=mirrordirector.raspbian.org
    DISTRIBUTION=raspbian
    RELEASE_ARCH=armhf
    RELEASE=jessie
    QEMU_BINARY=/usr/bin/qemu-arm-static
elif [ "${1}" = i686 ] ; then
    APT_SERVER=httpredir.debian.org
    DISTRIBUTION=debian
    RELEASE_ARCH=i686
    RELEASE=jessie
    QEMU_BINARY=/usr/bin/qemu-i386-static
else
    echo -e "The architecture is not supported"
    exit 1
fi


R=$(pwd)/build/chroot
SRC_DIR=/tmp

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

    APT_INCLUDES=apt-transport-https,apt-utils,ca-certificates,dialog,sudo,git,build-essential,bc,raspbian-archive-keyring,qt5-default,cmake

    # Base debootstrap
    http_proxy=${APT_PROXY} debootstrap --arch="${RELEASE_ARCH}" $REPOKEY --foreign --include="${APT_INCLUDES}" "${RELEASE}" "$R" "http://${APT_SERVER}/${DISTRIBUTION}"
    
    # Copy qemu emulator binary to chroot
    cp "${QEMU_BINARY}" "$R/usr/bin"

    # Copy debian-archive-keyring.pgp
    mkdir -p "$R/usr/share/keyrings"
    
    # Complete the bootstrapping process
    chroot_exec /debootstrap/debootstrap --second-stage
    
    # Mount required filesystems
    mount -t proc none "$R/proc"
    mount -t sysfs none "$R/sys"
    mount --bind /dev/pts "$R/dev/pts"
}


#########
## MAIN 
#########
echo -e "Prepare environment"
sudo rm -rf "${R}" > /dev/null 2>&1
get_repo_key
prepare_build_env

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
