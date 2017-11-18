all:
	@echo "Specify a target:\nmake pc\nmake rpi2"

rpi2:
	script -c 'sudo bash build.sh \"rpi2\"' ./build.log

pc:
	sudo bash build.sh "pc"

clean:
	sudo rm -rf output > /dev/null 2>&1
	sudo rm -rf build_root/results >/dev/null 2>&1
	sudo rm -rf build_root/cache >/dev/null 2>&1
