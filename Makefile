#!/usr/bin/make

# DO NOT USE IT
#test

all:
	@echo 'Specify a target and project:\nmake rpi2-tc-ass-jessie\nrpi2-tc-ass-buster\nmake rpi2-mirror\'

rpi2-tc-ass-jessie:
	sudo bash build.sh "rpi2" "ass" "jessie"

rpi2-tc-ass-buster:
	sudo bash build.sh "rpi2" "ass" "buster"

rpi2-mirror:
	sudo bash build.sh

help:
	@echo   'Cleaning target:'
	@echo   ' clean           - Remove most generated files but keep the logs'
	@echo   ' mrproper        - Remove all generated files + logs'

clean:
	sudo rm -rf ./images
	sudo rm build.log
