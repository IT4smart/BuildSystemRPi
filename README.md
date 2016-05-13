# rpi2-gen-image
## Introduction
`rpi2-gen-image.sh` is an advanced Debian Linux bootstrapping shell script for generating Debian OS images for the Raspberry 2 (RPi2) computer. The script at this time only supports the bootstrapping of the current stable Debian 8 "jessie" release.

## Build dependencies
The following list of Debian packages must be installed on the build system because they are essentially required for the bootstrapping process. The script will check if all required packages are installed and missing packages will be installed automatically if confirmed by the user.

  ```debootstrap debian-archive-keyring qemu-user-static binfmt-support dosfstools rsync bmap-tools whois git-core```

## Command-line parameters
The script accepts certain command-line parameters to enable or disable specific OS features, services and configuration settings. These parameters are passed to the `rpi2-gen-image.sh` script via (simple) shell-variables. Unlike environment shell-variables (simple) shell-variables are defined at the beginning of the command-line call of the `rpi2-gen-image.sh` script.

##### Command-line examples:
```shell
ENABLE_UBOOT=true ./rpi2-gen-image.sh
ENABLE_CONSOLE=false ENABLE_IPV6=false ./rpi2-gen-image.sh
ENABLE_WM=xfce4 ENABLE_FBTURBO=true ENABLE_MINBASE=true ./rpi2-gen-image.sh
ENABLE_HARDNET=true ENABLE_IPTABLES=true /rpi2-gen-image.sh
APT_SERVER=ftp.de.debian.org APT_PROXY="http://127.0.0.1:3142/" ./rpi2-gen-image.sh
ENABLE_MINBASE=true ./rpi2-gen-image.sh
BUILD_KERNEL=true ENABLE_MINBASE=true ENABLE_IPV6=false ./rpi2-gen-image.sh
BUILD_KERNEL=true KERNELSRC_DIR=/tmp/linux ./rpi2-gen-image.sh
ENABLE_MINBASE=true ENABLE_REDUCE=true ENABLE_MINGPU=true BUILD_KERNEL=true ./rpi2-gen-image.sh
```

#### APT settings:
##### `APT_SERVER`="ftp.debian.org"
Set Debian packages server address. Choose a server from the list of Debian worldwide [mirror sites](https://www.debian.org/mirror/list). Using a nearby server will probably speed-up all required downloads within the bootstrapping process.

##### `APT_PROXY`=""
Set Proxy server address. Using a local Proxy-Cache like `apt-cacher-ng` will speed-up the bootstrapping process because all required Debian packages will only be downloaded from the Debian mirror site once.

##### `APT_INCLUDES`=""
A comma seperated list of additional packages to be installed during bootstrapping.

#### Build settings
##### `BUILD_LOG`=true
Set logging for build.

#### General system settings:
##### `HOSTNAME`="rpi2-jessie"
Set system host name. It's recommended that the host name is unique in the corresponding subnet.

##### `PASSWORD`="raspberry"
Set system `root` password. The same password is used for the created user `pi`. It's **STRONGLY** recommended that you choose a custom password.

##### `DEFLOCAL`="en_US.UTF-8"
Set default system locale. This setting can also be changed inside the running OS using the `dpkg-reconfigure locales` command. The script variant `minbase` (ENABLE_MINBASE=true) doesn't install `locales`.

##### `TIMEZONE`="Europe/Berlin"
Set default system timezone. All available timezones can be found in the `/usr/share/zoneinfo/` directory. This setting can also be changed inside the running OS using the `dpkg-reconfigure tzdata` command.

##### `EXPANDROOT`=true
Expand the root partition and filesystem automatically on first boot.

#### Keyboard settings:
These options are used to configure keyboard layout in `/etc/default/keyboard` for console and Xorg. These settings can also be changed inside the running OS using the `dpkg-reconfigure keyboard-configuration` command.

##### `XKB_MODEL`=""
Set the name of the model of your keyboard type.

##### `XKB_LAYOUT`=""
Set the supported keyboard layout(s).

##### `XKB_VARIANT`=""
Set the supported variant(s) of the keyboard layout(s).

##### `XKB_OPTIONS`=""
Set extra xkb configuration options.

#### Networking settings (DHCP):
This setting is used to set up networking auto configuration in `/etc/systemd/network/eth.network`.

#####`ENABLE_DHCP`=true
Set the system to use DHCP. This requires an DHCP server.

#### Networking settings (static):
These settings are used to set up a static networking configuration in /etc/systemd/network/eth.network. The following static networking settings are only supported if `ENABLE_DHCP` was set to `false`.

#####`NET_ADDRESS`=""
Set a static IPv4 or IPv6 address and its prefix, separated by "/", eg. "192.169.0.3/24".

#####`NET_GATEWAY`=""
Set the IP address for the default gateway.

#####`NET_DNS_1`=""
Set the IP address for the first DNS server.

#####`NET_DNS_2`=""
Set the IP address for the second DNS server.

#####`NET_DNS_DOMAINS`=""
Set the default DNS search domains to use for non fully qualified host names.

#####`NET_NTP_1`=""
Set the IP address for the first NTP server.

#####`NET_NTP_2`=""
Set the IP address for the second NTP server.

#### Basic system features:
##### `ENABLE_CONSOLE`=true
Enable serial console interface. Recommended if no monitor or keyboard is connected to the RPi2. In case of problems fe. if the network (auto) configuration failed - the serial console can be used to access the system.

##### `ENABLE_IPV6`=true
Enable IPv6 support. The network interface configuration is managed via systemd-networkd.

##### `ENABLE_SSHD`=true
Install and enable OpenSSH service. The default configuration of the service doesn't allow `root` to login. Please use the user `pi` instead and `su -` or `sudo` to execute commands as root.

##### `ENABLE_RSYSLOG`=true
If set to false, disable and uninstall rsyslog (so logs will be available only
in journal files)

##### `ENABLE_SOUND`=true
Enable sound hardware and install Advanced Linux Sound Architecture.

##### `ENABLE_HWRANDOM`=true
Enable Hardware Random Number Generator. Strong random numbers are important for most network based communications that use encryption. It's recommended to be enabled.

##### `ENABLE_MINGPU`=false
Minimize the amount of shared memory reserved for the GPU. It doesn't seem to be possible to fully disable the GPU.

##### `ENABLE_DBUS`=true
Install and enable D-Bus message bus. Please note that systemd should work without D-bus but it's recommended to be enabled.

##### `ENABLE_XORG`=false
Install Xorg open-source X Window System.

##### `ENABLE_WM`=""
Install a user defined window manager for the X Window System. To make sure all X related package dependencies are getting installed `ENABLE_XORG` will automatically get enabled if `ENABLE_WM` is used. The `rpi2-gen-image.sh` script has been tested with the following list of window managers: `blackbox`, `openbox`, `fluxbox`, `jwm`, `dwm`, `xfce4`, `awesome`.

#### Advanced system features:
##### `ENABLE_MINBASE`=false
Use debootstrap script variant `minbase` which only includes essential packages and apt. This will reduce the disk usage by about 65 MB.

##### `ENABLE_REDUCE`=false
Reduce the disk usage by deleting all man pages and doc files (harsh). APT will be configured to use compressed package repository lists and no package caching files. If `ENABLE_MINGPU`=true unnecessary start.elf and fixup.dat files will also be removed from the boot partition. This will make it possible to generate output OS images with about 160MB of used disk space. It's recommended to use this parameter in combination with `ENABLE_MINBASE`=true.

##### `ENABLE_UBOOT`=false
Replace default RPi2 second stage bootloader (bootcode.bin) with U-Boot bootloader. U-Boot can boot images via the network using the BOOTP/TFTP protocol.

##### `ENABLE_FBTURBO`=false
Install and enable the hardware accelerated Xorg video driver `fbturbo`. Please note that this driver is currently limited to hardware accelerated window moving and scrolling.

##### `ENABLE_IPTABLES`=false
Enable iptables IPv4/IPv6 firewall. Simplified ruleset: Allow all outgoing connections. Block all incoming connections except to OpenSSH service.

##### `ENABLE_USER`=true
Create pi user with password raspberry

##### `ENABLE_ROOT`=true
Set root user password so root login will be enabled

##### `ENABLE_ROOT_SSH`=true
Enable password root login via SSH. May be a security risk with default
password, use only in trusted environments.

##### `ENABLE_HARDNET`=false
Enable IPv4/IPv6 network stack hardening settings.

##### `ENABLE_SPLITFS`=false
Enable having root partition on an USB drive by creating two image files: one for the `/boot/firmware` mount point, and another for `/`.

##### `CHROOT_SCRIPTS`=""
Path to a directory with scripts that should be run in the chroot before the image is finally built. Every executable file in this direcory is run in lexicographical order.

#### Kernel compilation:
##### `BUILD_KERNEL`=false
Build and install the latest RPi2 Linux kernel. Currently only the default RPi2 kernel configuration is used. Detailed configuration parameters for customizing the kernel and minor bug fixes still need to get implemented. feel free to help.

##### `KERNEL_THREADS`=1
Number of parallel kernel building threads. If the parameter is left untouched the script will automatically determine the number of CPU cores to set the number of parallel threads to speed the kernel compilation.

##### `KERNEL_HEADERS`=true
Install kernel headers with built kernel.

##### `KERNEL_MENUCONFIG`=false
Start `make menuconfig` interactive menu-driven kernel configuration. The script will continue after `make menuconfig` was terminated.

##### `KERNEL_REMOVESRC`=true
Remove all kernel sources from the generated OS image after it was built and installed.

##### `KERNELSRC_DIR`=""
Path to a directory of [RaspberryPi Linux kernel sources](https://github.com/raspberrypi/linux) that will be copied, configured, build and installed inside the chroot.

##### `KERNELSRC_CLEAN`=false
Clean the existing kernel sources directory `KERNELSRC_DIR` (using `make mrproper`) after it was copied to the chroot and before the compilation of the kernel has started. This setting will be ignored if no `KERNELSRC_DIR` was specified or if `KERNELSRC_PREBUILT`=true.

##### `KERNELSRC_CONFIG`=true
Run `make bcm2709_defconfig` (and optional `make menuconfig`) to configure the kernel sources before building. This setting is automatically set to `true` if no existing kernel sources directory was specified using `KERNELSRC_DIR`. This settings is ignored if `KERNELSRC_PREBUILT`=true.

##### `KERNELSRC_PREBUILT`=false
With this parameter set to true the script expects the existing kernel sources directory to be already successfully cross-compiled. The parameters `KERNELSRC_CLEAN`, `KERNELSRC_CONFIG` and `KERNEL_MENUCONFIG` are ignored and no kernel compilation tasks are performed.

### IT4S Custom ###
##### `ENABLE_CITRIX`=false
With this parameter set to true the script install all necessary dependencies and the citrix receiver and usb support.

##### `ENABLE_CITRIX_CUSTOM_CERT`=false
It's possible to deploy customer certificates for citrix receiver

##### `ENABLE_AUTOMOUNT`=false
Activate automounting of usb-devices with udisks-glue.


## Understanding the script
The functions of this script that are required for the different stages of the bootstrapping are split up into single files located inside the `bootstrap.d` directory. During the bootstrapping every script in this directory gets executed in lexicographical order:

| Script | Description |
| --- | --- |
| `10-bootstrap.sh` | Debootstrap basic system |
| `11-apt.sh` | Setup APT repositories |
| `12-locale.sh` | Setup Locales and keyboard settings |
| `13-kernel.sh` | Build and install RPi2 Kernel |
| `20-networking.sh` | Setup Networking |
| `21-firewall.sh` | Setup Firewall |
| `30-security.sh` | Setup Users and Security settings |
| `31-logging.sh` | Setup Logging |
| `41-uboot.sh` | Build and Setup U-Boot |
| `42-fbturbo.sh` | Build and Setup fbturbo Xorg driver |
| `50-firstboot.sh` | First boot actions |

All the required configuration files that will be copied to the generated OS image are located inside the `files` directory. It is not recommended to modify these configuration files manually.

| Directory | Description |
| --- | --- |
| `boot` | Boot and RPi2 configuration files |
| `dpkg` | Package Manager configuration |
| `firstboot` | Scripts that get executed on first boot  |
| `iptables` | Firewall configuration files |
| `locales` | Locales configuration |
| `modules` | Kernel Modules configuration |
| `mount` | Fstab configuration |
| `network` | Networking configuration files |
| `sysctl.d` | Swapping and Network Hardening configuration |
| `xorg` | fbturbo Xorg driver configuration |

### Custom files and directories
All scripts are located in the directory `custom.d`. During the bootstrapping every script in this directory gets executed in lexicographical order:
| Script | Description |
| --- | ---|
| `10-kernel.sh` | Set options for booting and kernel |
| `11-systemd.sh` | Setup systemd services |
| `20-desktop.sh` | Setup kiosk-desktop |
| `30-citrix.sh` | Install and setup citrix receiver |
| `90-apt.sh` | Install packages from repository |

All the required configuration files and packages that will be copies to the generated OS image are located inside the `files` directoy.

| Directory | Description |
| --- | --- |
| `Citrix` | Packages of citrix receiver and usb support |
| `Certificates` | Stored all certificates for the customer. Maybe we create subfolders for every customer |

## Logging of the bootstrapping process
All information related to the bootstrapping process and the commands executed by the `rpi2-gen-image.sh` script can easily be saved into a logfile. The common shell command `script` can be used for this purpose:

```shell
script -c 'APT_SERVER=ftp.de.debian.org ./rpi2-gen-image.sh' ./build.log
```

## Flashing the image file
After the image file was successfully created by the `rpi2-gen-image.sh` script it can be copied to the microSD card that will be used by the RPi2 computer. This can be performed by using the tools `bmaptool` or `dd`. Using `bmaptool` will probably speed-up the copy process because `bmaptool` copies more wisely than `dd`.

#####Flashing examples:
```shell
bmaptool copy ./images/jessie/2015-12-13-debian-jessie.img /dev/mmcblk0
dd bs=4M if=./images/jessie/2015-12-13-debian-jessie.img of=/dev/mmcblk0
```
If you have set `ENABLE_SPLITFS`, copy the `-frmw` image on the microSD card, then the `-root` one on the USB drive:
```shell
bmaptool copy ./images/jessie/2015-12-13-debian-jessie-frmw.img /dev/mmcblk0
bmaptool copy ./images/jessie/2015-12-13-debian-jessie-root.img /dev/sdc
```
