#!/usr/bin/make

all:
	@echo 'Specify a target and project:\nmake rpi2-thinclient\nmake rpi2-mirror\nrpi2-ubnt'

rpi2-thinclient:
	sudo bash build.sh "rpi2" "ass"

rpi2-ubnt:
	sudo bash build.sh "rpi2" "ubnt"

rpi2-mirror:
	sudo bash build.sh

help:
	@echo   'Cleaning target:'
	@echo   ' clean           - Remove most generated files but keep the logs'

clean:
	sudo rm -rf ./images
	sudo rm build.log
