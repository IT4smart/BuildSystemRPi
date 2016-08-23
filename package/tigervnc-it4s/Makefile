all:
	@echo "Specify a target:\nmake pc\nmake rpi2"

rpi2:
	script -c 'sudo bash build.sh \"rpi2\"' ./build.log

pc:
	script -c 'sudo bash build.sh \"pc\"' ./build.log

clean:
	sudo rm -rf build/chroot >/dev/null 2>&1
