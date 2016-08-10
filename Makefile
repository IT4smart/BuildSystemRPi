#!/usr/bin/make

# DO NOT USE IT
#test

all:
	@echo 'Specify a target and project:\nmake rpi2-thinclient\nmake rpi2-mirror\'

rpi2-thinclient:
	sudo bash build.sh "rpi2" "ass"

rpi2-mirror:
	sudo bash build.sh

help:
	@echo   'Cleaning target:'
	@echo   ' clean           - Remove most generated files but keep the logs'
	@echo   ' mrproper        - Remove all generated files + logs'

clean:
	sudo rm -rf ./images
	sudo rm build.log
