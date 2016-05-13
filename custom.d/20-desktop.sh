#
# Desktop enviroment
#

# copy .xsession
cp custom.d/files/Desktop/.xsession "$R/home/pi/.xsession"

# install nodm and qt5-default IT4S Apps
APT_INCLUDES="nodm qt5-default psmisc"
chroot_exec apt-get -qq -y install ${APT_INCLUDES}

# configure nodm
cp custom.d/files/Desktop/nodm "$R/etc/default/nodm"