#!/bin/bash

set -e
set -x

# Load utility functions
. ../../functions.sh

NUM_CPUS=`nproc`
echo "###############"
echo "### Using ${NUM_CPUS} cores"

# Config for chroot
APT_SERVER=mirrordirector.raspbian.org
DISTRIBUTION=raspbian
RELEASE_ARCH=armhf
RELEASE=jessie
QEMU_BINARY=/usr/bin/qemu-arm-static

R=$(pwd)/build/chroot
SRC_DIR=/tmp/


# Call "cleanup" function on various signals and errors
trap cleanup 0 1 2 3 6

function get_repo_key() {
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

    APT_INCLUDES=apt-transport-https,apt-utils,ca-certificates,dialog,sudo,git,build-essential,bc,raspbian-archive-keyring

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

function get_source_code() {
    local repo_path=$1
    git clone https://github.com/TigerVNC/tigervnc.git "${R}$repo_path"
}


sudo rm -rf "${R}"
mkdir -p "${R}"
get_repo_key
prepare_build_env
get_source_code "${SRC_DIR}"