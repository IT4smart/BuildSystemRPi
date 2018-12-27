#
# Desktop enviroment
#

# Install all essential things for thinclient use case
if [ ${ENABLE_THINCLIENT} = true ] ; then
  # copy .xsession
  cp custom.d/files/Desktop/.xsession "$R/home/pi/.xsession"

  # copy .xbindkeysrc for keybindings
  cp custom.d/files/Desktop/.xbindkeysrc "$R/home/pi/.xbindkeysrc"

  # install nodm and qt5-default for IT4smart Apps
  APT_INCLUDES="nodm qt5-default psmisc freerdp-x11 xbindkeys"
  chroot_exec apt-get -qq -y install ${APT_INCLUDES}

  # install IT4smart Apps
  APT_INCLUDES="rpb2-device-thinclient-it4smart=1.0.0~deb8"
  chroot_exec apt-get install -y ${APT_INCLUDES}

  # copy cleanup script
  cp custom.d/files/IT4smart/cleanup.sh "$R/opt/IT4smart/cleanup.sh"

  # copy script to enable sound on hdmi
  cp custom.d/files/IT4smart/sound.sh "$R/opt/IT4smart/sound.sh"

  # copy it4smart logo
  cp custom.d/files/IT4smart/IT4smart_Logo_small.png "$R/opt/IT4smart/startpage/Ressources/ass-logo.png"

  # configure nodm
  cp custom.d/files/Desktop/nodm "$R/etc/default/nodm"
fi
