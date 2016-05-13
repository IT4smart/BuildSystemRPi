#
# Configure systemd
#

# Load utility functions
. ./functions.sh

# timesyncd.conf
if [ -n "$NET_NTP_1"] && [ -n "$NET_NTP_2"] ; then
	# prepare custom ntp servers
	NTP="Servers= $NET_NTP_1 $NET_NTP_2" 

	# add custom ntp servers
	chroot_exec echo "$NTP" >> /etc/systemd/timesyncd.conf
fi

# USB mounting
if [ "$ENABLE_AUTOMOUNT" = true ] ; then
	# install required packages
	chroot_exec apt-get -qq -y install udisks-glue

	# copy pre configured service
	cp custom.d/files/Systemd/udisks-glue.service "$R/etc/systemd/system/udisks-glue.service"

	# activate systemd service
	chroot_exec systemctl enable udisks-glue.service

	# copy configuration file for mounting devices
	cp custom.d/files/Systemd/udisks-glue.conf "$R/etc/udisks-glue.conf"

	# copy polkit rule
	cp custom.d/files/Polkit-1/50-udisk-automount-group.pkla "$R/etc/polkit-1/localauthority/50-local.d/50-udisk-automount-group.pkla"
fi

