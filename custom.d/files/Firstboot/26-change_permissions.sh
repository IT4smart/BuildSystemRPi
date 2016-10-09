logger -t "rc.firstboot" "change permission"

# Change permission for .ICAClient directory
sudo chown -R pi:pi /home/pi/.ICAClient

# Change permission for IT4S
sudo chown -R pi:pi /opt/IT4S
