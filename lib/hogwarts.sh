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

	if [ "$1" = 'help' ]; then
		grep "()" $BASHGEMS_HOME/lib/hogwarts.sh
	fi

}

#use some command with proxy
#proxy npm install -g appium
proxy() {
	local http_proxy=""
	http_proxy=http://fq.testerhome.com:$(date +6%m%d) https_proxy=$http_proxy "$@"
}

chromedriver_download() {
	curl https://raw.githubusercontent.com/appium/appium/master/docs/en/writing-running-appium/web/chromedriver.md 2>/dev/null | grep "|" | grep -v "2.[0-9] " | grep -v "2.1[0-9]"
	echo chromedriver in CN: https://npm.taobao.org/mirrors/chromedriver
	echo chromedriver in US: http://chromedriver.storage.googleapis.com/
	echo chromedriver vs chrome version: https://github.com/appium/appium/blob/master/docs/en/writing-running-appium/web/chromedriver.md
}
