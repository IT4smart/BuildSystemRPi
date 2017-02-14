all:
	@echo "Specify a target:\nmake i686\nmake armv7\nmake amd64"

armv7:
	script -c 'sudo bash build.sh armv7' ./build.log

i686:
	script -c 'sudo bash build.sh i686' ./build.log

amd64:
	script -c 'sudo bash build.sh amd64' ./build.log

clean:
	sudo rm -rf build >/dev/null 2>&1