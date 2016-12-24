#
# Build and Setup RPi2 Kernel
#

# Load utility functions
. ./functions.sh

# Fetch and build latest raspberry kernel
if [ "$BUILD_KERNEL" = true ] ; then
  # Setup source directory
  mkdir -p "$R/usr/src"

  # Copy existing kernel sources into chroot directory
  if [ -n "$KERNELSRC_DIR" ] && [ -d "$KERNELSRC_DIR" ] ; then
    # Copy kernel sources
    cp -r "${KERNELSRC_DIR}" "${R}/usr/src"

    # Clean the kernel sources
    if [ "$KERNELSRC_CLEAN" = true ] && [ "$KERNELSRC_PREBUILT" = false ] ; then
      make -C "$R/usr/src/linux" ARCH="${KERNEL_ARCH}" CROSS_COMPILE="${CROSS_COMPILE}" mrproper
    fi
  else # KERNELSRC_DIR=""
    # Fetch current raspberrypi kernel sources
    git -C "$R/usr/src" clone --depth=1 https://github.com/raspberrypi/linux
  fi

  # Calculate optimal number of kernel building threads
  if [ "$KERNEL_THREADS" = "1" ] && [ -r /proc/cpuinfo ] ; then
    KERNEL_THREADS=$(grep -c processor /proc/cpuinfo)
  fi

  if [ "$KERNELSRC_PREBUILT" = false ] ; then
    if [ "$KERNELSRC_CONFIG" = true ] ; then
      # Load default raspberry kernel configuration
      make -C "$R/usr/src/linux" ARCH="${KERNEL_ARCH}" CROSS_COMPILE="${CROSS_COMPILE}" "${KERNEL_DEFCONFIG}"

      # Start menu-driven kernel configuration (interactive)
      if [ "$KERNEL_MENUCONFIG" = true ] ; then
        make -C "$R/usr/src/linux" ARCH="${KERNEL_ARCH}" CROSS_COMPILE="${CROSS_COMPILE}" menuconfig
      fi
    fi

    # Cross compile kernel and modules
    make -C "$R/usr/src/linux" -j${KERNEL_THREADS} ARCH="${KERNEL_ARCH}" CROSS_COMPILE="${CROSS_COMPILE}" zImage modules dtbs
  fi

  # Check if kernel compilation was successful
  if [ ! -r "$R/usr/src/linux/arch/${KERNEL_ARCH}/boot/zImage" ] ; then
    echo "error: kernel compilation failed! (zImage not found)"
    cleanup
    exit 1
  fi

  # Install kernel modules
  if [ "$ENABLE_REDUCE" = true ] ; then
    make -C "$R/usr/src/linux" ARCH="${KERNEL_ARCH}" CROSS_COMPILE="${CROSS_COMPILE}" INSTALL_MOD_STRIP=1 INSTALL_MOD_PATH=../../.. modules_install
  else
    make -C "$R/usr/src/linux" ARCH="${KERNEL_ARCH}" CROSS_COMPILE="${CROSS_COMPILE}" INSTALL_MOD_PATH=../../.. modules_install

    # Install kernel firmware
    make -C "$R/usr/src/linux" ARCH="${KERNEL_ARCH}" CROSS_COMPILE="${CROSS_COMPILE}" INSTALL_FW_PATH=../../../lib firmware_install
  fi

  # Install kernel headers
  if [ "$KERNEL_HEADERS" = true ] ; then
    make -C "$R/usr/src/linux" ARCH="${KERNEL_ARCH}" CROSS_COMPILE="${CROSS_COMPILE}" INSTALL_HDR_PATH=../.. headers_install
  fi

  # Prepare boot (firmware) directory
  mkdir "$R/boot/firmware/"

  # Get kernel release version
  KERNEL_VERSION=`cat "$R/usr/src/linux/include/config/kernel.release"`

  # Copy kernel configuration file to the boot directory
  cp "$R/usr/src/linux/.config" "$R/boot/config-${KERNEL_VERSION}"

  # Copy dts and dtb device tree sources and binaries
  mkdir "$R/boot/firmware/overlays/"
  cp "$R/usr/src/linux/arch/${KERNEL_ARCH}/boot/dts/"*.dtb "$R/boot/firmware/"
  cp "$R/usr/src/linux/arch/${KERNEL_ARCH}/boot/dts/overlays/"*.dtb* "$R/boot/firmware/overlays/"
  cp "$R/usr/src/linux/arch/${KERNEL_ARCH}/boot/dts/overlays/README" "$R/boot/firmware/overlays/"

  # Convert kernel zImage and copy it to the boot directory
  "$R/usr/src/linux/scripts/mkknlimg" "$R/usr/src/linux/arch/${KERNEL_ARCH}/boot/zImage" "$R/boot/firmware/kernel7.img"

  # Remove kernel sources
  if [ "$KERNEL_REMOVESRC" = true ] ; then
    rm -fr "$R/usr/src/linux"
  fi

  # Install raspberry bootloader and flash-kernel packages
  chroot_exec apt-get -qq -y --no-install-recommends install raspberrypi-bootloader-nokernel
else # BUILD_KERNEL=false
  # Kernel installation
  #chroot_exec apt-get -qq -y --no-install-recommends install linux-image-"${COLLABORA_KERNEL}" raspberrypi-bootloader-nokernel
  chroot_exec apt-get -qq -y --no-install-recommends install raspberrypi-kernel raspberrypi-bootloader

  # Install flash-kernel last so it doesn't try (and fail) to detect the platform in the chroot
  #chroot_exec apt-get -qq -y install flash-kernel

  # Check if kernel installation was successful
  #VMLINUZ="$(ls -1 ${R}/boot/vmlinuz-* | sort | tail -n 1)"
  #if [ -z "$VMLINUZ" ] ; then
  #  echo "error: kernel installation failed! (/boot/vmlinuz-* not found)"
  #  cleanup
  #  exit 1
  #fi
  # Copy vmlinuz kernel to the boot directory
  #install_readonly "${VMLINUZ}" "$R/boot/${KERNEL_IMAGE}"
fi

# Setup firmware boot cmdline
if [ "$ENABLE_SPLITFS" = true ] ; then
  CMDLINE="dwc_otg.lpm_enable=0 root=/dev/sda1 rootfstype=ext4 rootflags=commit=100,data=writeback elevator=deadline rootwait net.ifnames=1 ${CMDLINE}"
else
  CMDLINE="dwc_otg.lpm_enable=0 root=/dev/mmcblk0p2 rootfstype=ext4 rootflags=commit=100,data=writeback elevator=deadline rootwait net.ifnames=1 ${CMDLINE}"
fi

# Add serial console support
if [ "$ENABLE_CONSOLE" = true ] ; then
  CMDLINE="${CMDLINE} console=ttyAMA0,115200 kgdboc=ttyAMA0,115200"
fi

# Remove IPv6 networking support
if [ "$ENABLE_IPV6" = false ] ; then
  CMDLINE="${CMDLINE} ipv6.disable=1"
fi

# Custom IT4S
if [ "$ENABLE_BOOTSPLASH" = true ] ; then
    CMDLINE="${CMDLINE} console=null fsck.repair=yes quiet splash plymouth.ignore-serial-consoles"
else
    CMDLINE="${CMDLINE} console=tty1 fsck.repair=yes"
fi

# Install firmware boot cmdline
echo "${CMDLINE}" > "$R/boot/cmdline.txt"

# Install firmware config
install_readonly files/boot/config.txt "$R/boot/config.txt"

# Setup minimal GPU memory allocation size: 16MB (no X)
if [ "$ENABLE_MINGPU" = true ] ; then
  sed -i "s/^gpu_mem=256/gpu_mem=16/" "$R/boot/config.txt"
fi

# Create firmware configuration and cmdline symlinks
#ln -sf firmware/config.txt "$R/boot/config.txt"
#ln -sf firmware/cmdline.txt "$R/boot/cmdline.txt"

# Install and setup kernel modules to load at boot
mkdir -p "$R/lib/modules-load.d/"
install_readonly files/modules/rpi2.conf "$R/lib/modules-load.d/rpi2.conf"

# Load hardware random module at boot
if [ "$ENABLE_HWRANDOM" = true ] ; then
  sed -i "s/^# bcm2708_rng/bcm2708_rng/" "$R/lib/modules-load.d/rpi2.conf"
fi

# Load sound module at boot
if [ "$ENABLE_SOUND" = true ] ; then
  sed -i "s/^# snd_bcm2835/snd_bcm2835/" "$R/lib/modules-load.d/rpi2.conf"
fi

# Install kernel modules blacklist
mkdir -p "$R/etc/modprobe.d/"
install_readonly files/modules/raspi-blacklist.conf "$R/etc/modprobe.d/raspi-blacklist.conf"

# Install and setup fstab
install_readonly files/mount/fstab "$R/etc/fstab"
if [ "$ENABLE_SPLITFS" = true ] ; then
  sed -i 's/mmcblk0p2/sda1/' "$R/etc/fstab"
fi

# Install sysctl.d configuration files
install_readonly files/sysctl.d/81-rpi-vm.conf "$R/etc/sysctl.d/81-rpi-vm.conf"
