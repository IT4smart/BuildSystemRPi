all:
	@echo "Specify a target:\nmake i686\nmake rpi2"

rpi2:
	script -c 'sudo bash build.sh \"rpi2\"' ./build.log

pc:
	script -c 'sudo bash build.sh \"i686\"' ./build.log

clean:
	sudo rm -rf files/opt/IT4S > /dev/null 2>&1
	sudo rm -rf build >/dev/null 2>&1
    