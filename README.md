

## BashGems
这是TesterHome TTF旗下的一个开源项目，用于增强Bash功能，BashGems通过加载各类有用的函数实现对系统命令的扩展

## Get Start
quick install
```bash
# install
wget https://github.com/seveniruby/bashgems/archive/master.zip -O /tmp/bashgems.zip
unzip /tmp/bashgems.zip -d /tmp/bashgems
mv /tmp/bashgems/bashgems-master/ ~/.bashgems
echo '[ -f  ~/.bashgems/bin/bashgems.sh ] && . ~/.bashgems/bin/bashgems.sh' >>  ~/.bash_profile
# load bashgems
. ~/.bash_profile
# now you can use some enhance function
proxy npm install -g appium --verbose
```


use github to install
```shell
# download
git clone https://github.com/seveniruby/bashgems.git ~/.bashgems
# add to shell profile for auto load
echo '[ -f  ~/.bashgems/bin/bashgems.sh ] && . ~/.bashgems/bin/bashgems.sh' >>  ~/.bash_profile
# load bashgems
. ~/.bash_profile
# now you can use some enhance function 
proxy npm install -g appium --verbose
```
为了让测试工程师安装自动化测试工具更方便，我们提供了proxy命令来确保安装顺利。
更多功能详见代码。

## More
- TesterHome: https://testerhome.com
- TTF: https://testerhome.com/topics/15522
- BashGems: https://github.com/seveniruby/bashgems.git

## Maintainers
霍格沃兹测试学院
