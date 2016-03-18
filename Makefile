#!/usr/bin/make

# DO NOT USE IT


rpi2-thinclient:
        # Logging?
        export BUILD_LOG=true

        # set customization options
        export DEFLOCAL="de_DE.UTF-8"
        export XKB_LAYOUT="de"
        export ENABLE_IPV6=false
        export ENABLE_CONSOLE=false
        export ENABLE_SPLASH=false
        export ENABLE_WM="xfce4"
        export APT_SERVER=mirrordirector.raspbian.org
        export DISTRIBUTION=raspbian
	    ./build.sh

rpi2-mirror:
	    ./build.sh

help:
        @echo   'Cleaning target:'
        @echo   ' clean           - Remove most generated files but keep the logs'
        @echo   ' mrproper        - Remove all generated files + logs'

clean:
	    rm -rf ./images
