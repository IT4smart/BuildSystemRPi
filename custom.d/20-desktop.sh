#
# Desktop enviroment
#

# copy .xsession
cp custom.d/files/Desktop/.xsession "$R/home/pi/.xsession"

# copy .xbindkeysrc for keybindings
cp custom.d/files/Desktop/.xbindkeysrc "$R/home/pi/.xbindkeysrc"

# install nodm and qt5-default for IT4S Apps
APT_INCLUDES="nodm qt5-default psmisc freerdp-x11 xbindkeys"
chroot_exec apt-get -qq -y install ${APT_INCLUDES}

# install StartPage
cp custom.d/files/IT4S/armv7-startpage.deb "$R/tmp/armv7-startpage.deb"
chroot_exec dpkg -i /tmp/armv7-startpage.deb

# install ConfigPage
cp custom.d/files/IT4S/armv7-configpage.deb "$R/tmp/armv7-configpage.deb"
chroot_exec dpkg -i /tmp/armv7-configpage.deb

# configure nodm
cp custom.d/files/Desktop/nodm "$R/etc/default/nodm"