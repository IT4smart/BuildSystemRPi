all:
	@echo "Specify a target:\nmake i386\nmake amd64\nmake armv7"

armv7:
	script -c 'sudo bash build.sh armv7' ./build.log

i386:
	script -c 'sudo bash build.sh i386' ./build.log
    
amd64:
	script -c 'sudo bash build.sh amd64' ./build.log

clean:
	sudo rm -rf build/chroot >/dev/null 2>&1
