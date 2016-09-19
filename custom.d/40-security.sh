#
# Custom security
#

# add user `pi` to sudoers file
echo "pi   ALL = NOPASSWD: ALL" >> "${R}/etc/sudoers"