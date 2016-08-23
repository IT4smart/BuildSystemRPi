#!/bin/bash

# Based on the script from hypriot https://github.com/hypriot/rpi-kernel
#
#

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


SRC_DIR=$(pwd)
BUILD_ROOT=/tmp/build_root
R=$(pwd)/build_root/chroot
BUILD_CACHE=/tmp/cache
ARM_TOOLS=$BUILD_CACHE/tools
LINUX_KERNEL=$BUILD_CACHE/linux-kernel
#LINUX_KERNEL_COMMIT=35467dc7630af60abacc330f64029d081f160530 # Linux 4.4.15
RASPBERRY_FIRMWARE=$BUILD_CACHE/rpi_firmware

LINUX_KERNEL_CONFIGS=$SRC_DIR/kernel_configs

NEW_VERSION=`date +%Y%m%d-%H%M%S`
BUILD_RESULTS=$BUILD_ROOT/results/kernel-$NEW_VERSION

X64_CROSS_COMPILE_CHAIN=arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian-x64

declare -A CCPREFIX
CCPREFIX["rpi1"]=$ARM_TOOLS/$X64_CROSS_COMPILE_CHAIN/bin/arm-linux-gnueabihf-
CCPREFIX["rpi2_3"]=$ARM_TOOLS/$X64_CROSS_COMPILE_CHAIN/bin/arm-linux-gnueabihf-

declare -A IMAGE_NAME
IMAGE_NAME["rpi1"]=kernel.img
IMAGE_NAME["rpi2_3"]=kernel7.img

# Call "cleanup" function on various signals and errors
trap cleanup 0 1 2 3 6

function get_repo_key() {
REPOKEY=""
if [ "$DISTRIBUTION" = raspbian ] ; then
 REPOKEY="build_root/raspbianrepokey.gpg"
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


function create_dir_for_build_user () {
    local target_dir=$1

    chroot_exec sudo mkdir -p $target_dir
    #sudo chown $BUILD_USER:$BUILD_GROUP $target_dir
}

function setup_build_dirs () {
  for dir in $BUILD_ROOT $BUILD_CACHE $BUILD_RESULTS $ARM_TOOLS $LINUX_KERNEL $RASPBERRY_FIRMWARE; do
    create_dir_for_build_user $dir
  done
}

function clone_or_update_repo_for () {
  local repo_url=$1
  local repo_path=$2
  local repo_commit=$3

  if [ ! -z "${repo_commit}" ]; then
    chroot_exec rm -rf $repo_path
  fi
  if [ -d ${repo_path}/.git ]; then
    chroot_exec cd $repo_path
    chroot_exec git reset --hard HEAD
    chroot_exec git pull
  else
    echo "Cloning $repo_path with commit $repo_commit"
    git clone --depth=1 $repo_url "${R}${repo_path}"
    
    # find out how this work with checking out a specific commit.
    #if [ ! -z "${repo_commit}" ]; then
    #  cd $repo_path && git checkout -qf ${repo_commit}
    #fi
  fi
}

function setup_arm_cross_compiler_toolchain () {
  echo "### Check if Raspberry Pi Crosscompiler repository at ${ARM_TOOLS} is still up to date"
  clone_or_update_repo_for 'https://github.com/raspberrypi/tools.git' $ARM_TOOLS ""
}

function setup_linux_kernel_sources () {
  echo "### Check if Raspberry Pi Linux Kernel repository at ${LINUX_KERNEL} is still up to date"
  clone_or_update_repo_for 'https://github.com/raspberrypi/linux.git' $LINUX_KERNEL $LINUX_KERNEL_COMMIT
  echo "### Cleaning .version file for deb packages"
  chroot_exec rm -f $LINUX_KERNEL/.version
}

function setup_rpi_firmware () {
  echo "### Check if Raspberry Pi Firmware repository at ${LINUX_KERNEL} is still up to date"
  clone_or_update_repo_for 'https://github.com/RPi-Distro/firmware' $RASPBERRY_FIRMWARE ""
}

function prepare_kernel_building () {
  sudo rm -rf "${R}"
  get_repo_key
  prepare_build_env
  setup_build_dirs
  setup_arm_cross_compiler_toolchain
  setup_linux_kernel_sources
  setup_rpi_firmware
}

create_kernel_for () {
  echo "###############"
  echo "### START building kernel for ${PI_VERSION}"

  local PI_VERSION=$1


  # add kernel branding for HypriotOS
  sed -i 's/^EXTRAVERSION =.*/EXTRAVERSION = -it4s/g' "$R$LINUX_KERNEL/Makefile"

  # save git commit id of this build
  local KERNEL_COMMIT=`git rev-parse HEAD`
  echo "### git commit id of this kernel build is ${KERNEL_COMMIT}"

  # clean build artifacts
  chroot_exec make -C "${LINUX_KERNEL}" ARCH=arm clean

  # copy kernel configuration file over
  #cp $LINUX_KERNEL_CONFIGS/${PI_VERSION}_docker_kernel_config $LINUX_KERNEL/.config

  echo "### building kernel"
  chroot_exec mkdir -p $BUILD_RESULTS/$PI_VERSION
  echo $KERNEL_COMMIT > $R$BUILD_RESULTS/kernel-commit.txt
  if [ ! -z "${MENUCONFIG}" ]; then
    echo "### starting menuconfig"
    #ARCH=arm CROSS_COMPILE=${CCPREFIX[$PI_VERSION]} make menuconfig
    make -C "${LINUX_KERNEL}" ARCH=arm menuconfig
    echo "### saving new config back to $LINUX_KERNEL_CONFIGS/${PI_VERSION}_docker_kernel_config"
    cp $LINUX_KERNEL/.config $LINUX_KERNEL_CONFIGS/${PI_VERSION}_docker_kernel_config
    return
  fi

  echo "### load default kernel config"
  #chroot_exec make -C "${LINUX_KERNEL}" ARCH=arm CROSS_COMPILE=${CCPREFIX[${PI_VERSION}]} bcm2709_defconfig -j$NUM_CPUS
  chroot_exec make -C "${LINUX_KERNEL}" ARCH=arm bcm2709_defconfig -j$NUM_CPUS
  
  echo "### building kernel"
  #chroot_exec make -C "${LINUX_KERNEL}" -j"${NUM_CPUS}" ARCH=arm CROSS_COMPILE=${CCPREFIX[${PI_VERSION}]} zImage modules dtbs
  chroot_exec make -C "${LINUX_KERNEL}" -j"${NUM_CPUS}" ARCH=arm zImage modules dtbs

  chroot_exec ${LINUX_KERNEL}/scripts/mkknlimg $LINUX_KERNEL/arch/arm/boot/Image $BUILD_RESULTS/$PI_VERSION/${IMAGE_NAME[${PI_VERSION}]}

  echo "### installing kernel modules"
  chroot_exec mkdir -p $BUILD_RESULTS/$PI_VERSION/modules
  #chroot_exec make ARCH=arm CROSS_COMPILE=${CCPREFIX[${PI_VERSION}]} INSTALL_MOD_PATH=$BUILD_RESULTS/$PI_VERSION/modules modules_install -j$NUM_CPUS
  chroot_exec make -C "${LINUX_KERNEL}" ARCH=arm INSTALL_MOD_PATH=$BUILD_RESULTS/$PI_VERSION/modules modules_install -j$NUM_CPUS

  # remove symlinks, mustn't be part of raspberrypi-bootloader*.deb
  echo "### removing symlinks"
  chroot_exec rm -f $BUILD_RESULTS/$PI_VERSION/modules/lib/modules/*/build
  chroot_exec rm -f $BUILD_RESULTS/$PI_VERSION/modules/lib/modules/*/source

  if [[ ! -z $CIRCLE_ARTIFACTS ]]; then
    chroot_exec cp ../*.deb $CIRCLE_ARTIFACTS
  fi
  chroot_exec mv ../*.deb $BUILD_RESULTS
  echo "###############"
  echo "### END building kernel for ${PI_VERSION}"
  echo "### Check the $BUILD_RESULTS/$PI_VERSION/kernel.img and $BUILD_RESULTS/$PI_VERSION/modules directory on your host machine."
}

function create_kernel_deb_packages () {
  echo "###############"
  echo "### START building kernel DEBIAN PACKAGES"

  PKG_TMP=`mktemp -d`

  NEW_KERNEL=$PKG_TMP/raspberrypi-kernel-${NEW_VERSION}

  create_dir_for_build_user $NEW_KERNEL

  # copy over source files for building the packages
  echo "copying firmware from $RASPBERRY_FIRMWARE to $NEW_KERNEL"
  # skip modules directory from standard tree, because we will our on modules below
  tar --exclude=modules -C $RASPBERRY_FIRMWARE -cf - . | tar -C $NEW_KERNEL -xvf -
  # create an empty modules directory, because we have skipped this above
  mkdir -p $NEW_KERNEL/modules/
  cp -r $SRC_DIR/debian $NEW_KERNEL/debian
  touch $NEW_KERNEL/debian/files

  for pi_version in ${!CCPREFIX[@]}; do
    cp $BUILD_RESULTS/$pi_version/${IMAGE_NAME[${pi_version}]} $NEW_KERNEL/boot
    cp -R $BUILD_RESULTS/$pi_version/modules/lib/modules/* $NEW_KERNEL/modules
  done
  # build debian packages
  cd $NEW_KERNEL

  dch -v ${NEW_VERSION} --package raspberrypi-firmware 'add IT4S custom kernel'
  debuild --no-lintian -ePATH=${PATH}:$ARM_TOOLS/$X64_CROSS_COMPILE_CHAIN/bin -b -aarmhf -us -uc
  cp ../*.deb $BUILD_RESULTS
  if [[ ! -z $CIRCLE_ARTIFACTS ]]; then
    cp ../*.deb $CIRCLE_ARTIFACTS
  fi

  chroot_exec echo "###############"
  chroot_exec echo "### FINISH building kernel DEBIAN PACKAGES"
}


##############
###  main  ###
##############

echo "*** all parameters are set ***"
echo "*** the kernel timestamp is: $NEW_VERSION ***"
echo "#############################################"

# clear build cache to fetch the current raspberry/firmware
sudo rm -fr $RASPBERRY_FIRMWARE

# setup necessary build environment: dir, repos, etc.
prepare_kernel_building

# create kernel, associated modules
for pi_version in ${!CCPREFIX[@]}; do
  create_kernel_for $pi_version
done

# create kernel packages
#create_kernel_deb_packages

# running in vagrant VM
#if [ -d /vagrant ]; then
  # copy build results to synced vagrant host folder
#  FINAL_BUILD_RESULTS=/vagrant/build_results/$NEW_VERSION
#else
  # running in drone build
#  FINAL_BUILD_RESULTS=$SRC_DIR/output/$NEW_VERSION
#fi

#echo "###############"
#echo "### Copy deb packages to $FINAL_BUILD_RESULTS"
#mkdir -p $FINAL_BUILD_RESULTS
#cp $BUILD_RESULTS/*.deb $FINAL_BUILD_RESULTS
#cp $BUILD_RESULTS/*.txt $FINAL_BUILD_RESULTS

#ls -lh $FINAL_BUILD_RESULTS
cleanup
echo "*** kernel build done"