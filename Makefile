#!/usr/bin/make

all:
	@echo 'Specify a target and project:\nmake rpi2-tc-ass-jessie\nrpi2-tc-ass-buster\nmake rpi2-mirror\nrpi2-ubnt'

rpi2-tc-ass-jessie:
	sudo bash build.sh "rpi2" "ass" "jessie"

rpi2-tc-ass-buster:
	sudo bash build.sh "rpi2" "ass" "buster"

rpi2-ubnt-buster:
	sudo bash build.sh "rpi2" "ubnt" "buster"

rpi2-ubnt:
	sudo bash build.sh "rpi2" "ubnt" "jessie"

rpi2-mirror:
	sudo bash build.sh

help:
	@echo   'Cleaning target:'
	@echo   ' clean           - Remove most generated files but keep the logs'

clean:
	sudo rm -rf ./images
	sudo rm build.log
