#
# Desktop enviroment
#

# copy .xsession
cp custom.d/files/Desktop/.xsession "$R/home/pi/.xsession"

# install nodm and qt5-default IT4S Apps
APT_INCLUDES="nodm qt5-default psmisc freerdp-x11"
chroot_exec apt-get -qq -y install ${APT_INCLUDES}

# install StartPage
cp custom.d/files/IT4S/armv7-startpage.deb "$R/tmp/armv7-startpage.deb"
chroot_exec dpkg -i /tmp/armv7-startpage.deb

# configure nodm
cp custom.d/files/Desktop/nodm "$R/etc/default/nodm"