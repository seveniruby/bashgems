bashgems_bgem_test()
{

scp bin/bashgem.sh  bb-testing-iknow09.vm.baidu.com:/tmp/
ssh bb-testing-iknow09.vm.baidu.com '
. ~/.bash_profile
. /tmp/bashgem.sh
echo "test bashgems_install"
bashgems_install

echo "test install"
bgem -install btest
find  $BASHGEMS_HOME |grep -v ".svn"

echo "test uninstall"
bgem -uninstall btest
find  $BASHGEMS_HOME |grep -v ".svn"

echo test done
'
}


bashgems_bgem_source_test()
{
	bgem -list -remote
	bgem -source https://svn.baidu.com/app-test/search/sep/trunk/bashgems/gems
	bgem -list -remote
}

bashgems_bgem_install_test()
{
	bgem -install demo
	bgem -uninstall demo
	bgem -source https://svn.baidu.com/app-test/search/sep/trunk/bashgems/gems
	bgem -install demo
	bgem -load demo
}


bashgems_test()
{
	BASHGEMS_HOME=$PWD
	bashgems_install 
	ls
	bashgems_bgem_source_test
	bashgems_bgem_install_test
}


