#
# Boot environment
#

# only add those lines if we need a splash screen.
if [ "$ENABLE_BOOTSPLASH" = true ] ; then
	# install plymouth themes
	APT_INCLUDES="plymouth-themes"
	chroot_exec apt-get -qq -y install ${APT_INCLUDES}

	# change plymouth theme from text to spinfinity
	echo "[Daemon]" >> "$R/etc/plymouth/plymouthd.conf"
	echo "Theme=spinfinity" >> "$R/etc/plymouth/plymouthd.conf"

	# change boot logo from debian to it4s
	cp "custom.d/files/Desktop/IT4S_151px_319px.png" "$R/usr/share/plymouth/debian-logo.png"
fi

APT_INCLUDES="base-files-it4smart"
chroot_exec apt-get -y -qq install ${APT_INCLUDES}
