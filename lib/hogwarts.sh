hogwarts() {
	echo '
#      __                                    __      
#     / /_  ____  ____ __      ______ ______/ /______
#    / __ \/ __ \/ __ `/ | /| / / __ `/ ___/ __/ ___/
#   / / / / /_/ / /_/ /| |/ |/ / /_/ / /  / /_(__  ) 
#  /_/ /_/\____/\__, / |__/|__/\__,_/_/   \__/____/  
#              /____/                                
'
	echo "Hogwarts Testing Kit"
	echo

	local help install start
	ARGS="install start" pp "$@"

	if [ -n "$help" -o "$#" = 0 ]; then
		echo "hogwarts provide such functions"
		grep "() *{" $BASHGEMS_HOME/lib/hogwarts.sh
		return
	fi
	if [ -n "$install" ]; then
		eval hogwarts_install_$install
	fi
}

#use some command with proxy
#proxy npm install -g appium
proxy() {
	local http_proxy https_proxy
	http_proxy=http://112.126.81.122:$(date +6%m%d) https_proxy=$http_proxy "$@"
}

chromedriver_list() {
	curl https://raw.githubusercontent.com/appium/appium/master/docs/en/writing-running-appium/web/chromedriver.md 2>/dev/null | grep "|" | grep -v "2.[0-9] " | grep -v "2.1[0-9]"
	echo chromedriver in CN: https://npm.taobao.org/mirrors/chromedriver
	echo chromedriver in US: http://chromedriver.storage.googleapis.com/
	echo chromedriver vs chrome version: https://github.com/appium/appium/blob/master/docs/en/writing-running-appium/web/chromedriver.md
}

hogwarts_install_test() {
	echo "${FUNCNAME[1]} -> ${FUNCNAME[0]}"
}
hogwarts_install_stf() {
	brew install rethinkdb graphicsmagick zeromq protobuf yasm pkg-config
	npm install -g stf
}

Hogwarts_start_stf() {
	rethinkdb &
	stf local
}

hogwarts_install_jenkins() {
	local image=jenkins/jenkins:lts
	docker run -ti --rm --entrypoint="/bin/bash" $image -c "whoami && id"
	echo "maybe you need chown -R 1000 ~/jenkins/hogwarts"
	docker run -d --name jenkins_hogwarts \
		-p 8080:8080 -p 50000:50000 \
		-v ~/jenkins/hogwarts:/var/jenkins_home \
		$image
	echo "you need use such password for init"
	docker exec jenkins_hogwarts sh -c 'cat /var/jenkins_home/secrets/initialAdminPassword'
}

hogwarts_install_appium() {
	if which node; then
		npm version
	else
		echo you should install node 8 or above
		if which brew; then
			brew install node
		else
			echo you should install brew by /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
		fi
	fi
	which java || echo you should install java
	which adb || echo you should install android sdk and put adb directory in your PATH
	echo search appium versions
	proxy npm view appium versions --json | tail
	echo start install appium
	proxy npm install -g appium --verbose
	echo start install ios testing toolkit
	if which brew; then
		brew info libimobiledevice || brew install libimobiledevice
		brew info ios-webkit-debug-proxy || brew install ios-webkit-debug-proxy
	fi
	echo start install ios-deploy
	npm info ios-deploy || npm install -g ios-deploy --verbose
    appium --version
}

hogwarts_get_capabilitys_android(){
	local info=$(adb logcat -d "*:S" "ActivityManager:I" | grep -i displayed | grep -o '[^/ ]*/[^: ]*')
	local package=$(echo "$info" | awk -F/ '{print $1}' | tail -1)
	local activity=$(echo "$info" | grep $package | head -1 | awk -F/ '{print $2}')
	echo "
	{
		\"platformName\": \"android\",
		\"deviceName\": \"hogwarts\",
		\"automationName\": \"uiautomator2\",
		\"appPackage\": \"$package\",
		\"appActivity\": \"$activity\"
	}
	"
}

hogwarts_list_avds(){
	
}

hogwarts_start_avd(){
	local name=$(emulator -list-avds | grep $1)
	(cd $(dirname $(which emulator));emulator @$name)
}
