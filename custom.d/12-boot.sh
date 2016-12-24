#
# Boot environment
#

# change plymouth theme from text to spinfinity
echo "[Daemon]" >> "$R/etc/plymouth/plymouthd.conf"
echo "Theme=spinfinity" >> "$R/etc/plymouth/plymouthd.conf"

# change boot logo from debian to it4s
cp "custom.d/files/Desktop/IT4S_151px_319px.png" "$R/usr/share/plymouth/debian-logo.png"