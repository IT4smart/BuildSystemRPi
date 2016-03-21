#
# Debootstrap basic system
#

# Load utility functions
. ./functions.sh

# For Raspbian we didn't know the GPG - Key so we have to export it
#if [ ${DISTRIBUTION} = "raspbian" ] ; then
#  if [ -f files/apt/raspbian.public.key ] ; then
#    rm files/apt/raspbian.public.key
#  fi
#  wget http://debian.raspbian.com/raspbian.public.key -O files/apt/raspbian.public.key
#  gpg --import files/apt/raspbian.public.key 
#fi

# Base debootstrap (unpack only)
#
# Todo
# - in future add a all keyrings

if [ "$ENABLE_MINBASE" = true ] ; then
  http_proxy=${APT_PROXY} debootstrap --arch="${RELEASE_ARCH}" --variant=minbase $REPOKEY --foreign --include="${APT_INCLUDES}" "${RELEASE}" "$R" "http://${APT_SERVER}/${DISTRIBUTION}"
else
  http_proxy=${APT_PROXY} debootstrap --arch="${RELEASE_ARCH}" $REPOKEY --foreign --include="${APT_INCLUDES}" "${RELEASE}" "$R" "http://${APT_SERVER}/${DISTRIBUTION}"
fi

# Copy qemu emulator binary to chroot
cp "${QEMU_BINARY}" "$R/usr/bin"

# Copy debian-archive-keyring.pgp
mkdir -p "$R/usr/share/keyrings"

cp /usr/share/keyrings/debian-archive-keyring.gpg "$R/usr/share/keyrings/debian-archive-keyring.gpg"

# Complete the bootstrapping process
chroot_exec /debootstrap/debootstrap --second-stage

# Mount required filesystems
mount -t proc none "$R/proc"
mount -t sysfs none "$R/sys"
mount --bind /dev/pts "$R/dev/pts"
