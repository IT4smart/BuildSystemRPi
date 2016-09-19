all:
	@echo "Specify a target:\nmake i686\nmake armv7"

armv7:
	script -c 'sudo bash build.sh armv7' ./build.log

i686:
	script -c 'sudo bash build.sh i686' ./build.log

clean:
	sudo rm -rf files/opt/IT4S > /dev/null 2>&1
	sudo rm -rf build >/dev/null 2>&1
    
