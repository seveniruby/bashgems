#!/usr/bin/env bash

#class:basic
#user:yansheng.huangys
#date:200910302209
#cat:bash
#pp -p 1 -s 2 -d 
#then the result is 
#p=1 s=2 d=""
#so you can use it in your functions for parameters parsing
pp()
{
  local kkk vvv count=$# i
  #while [[ -n "$1" ]]
  for((i=1;i<=$count;i++))
  do
      [[ -z "$1" ]] && shift && continue
      kkk="${1:1}"
      if [[ "${1:0:1}" = '-' && "$1" == -[a-zA-Z]* ]]
      then
          eval "$kkk=\"${2//\"/\\\"}\""  #unset the var and set value to it
      fi
      shift;
  done
}


bashgems_install()
{
  echo install
  wget https://github.com/seveniruby/bashgems/archive/master.zip -O /tmp/bashgems.zip
  unzip /tmp/bashgems.zip -d /tmp/bashgems
  mv /tmp/bashgems/bashgems-master/ ~/.bashgems
  echo '[ -f  ~/.bashgems/bin/bashgems.sh ] && . ~/.bashgems/bin/bashgems.sh' >>  ~/.bash_profile
  echo load bashgems
  . ~/.bash_profile
  echo test now you can use some enhance function
  proxy npm install -g appium --verbose
}

logo()
{
echo '
#     __            __            __
#    / /____  _____/ /____  _____/ /_  ____  ____ ___  ___
#   / __/ _ \/ ___/ __/ _ \/ ___/ __ \/ __ \/ __ `__ \/ _ \
#  / /_/  __(__  ) /_/  __/ /  / / / / /_/ / / / / / /  __/
#  \__/\___/____/\__/\___/_/  /_/ /_/\____/_/ /_/ /_/\___/
#
'
}
bgem()
{
  local source install uninstall load info use list=_ remote=_ update=_  publish=_ m=_
  
  if [[ $# != 0 ]]
  then
    pp "$@"
    if [[ -n "$source" ]]
    then
      GEMS_SITE=$source
    fi
    if [[ -n "$install" ]]
    then
      svn co "$GEMS_SITE/$install" $BASHGEMS_HOME/gems/$install
    fi
    if [[ -n "$uninstall" ]]
    then
      rm $BASHGEMS_HOME/gems/$uninstall -rf 
    fi
    #bgem -update unittest
    #bgem -update 
    if [[ _ != "$update"  && -n "$update" ]]
    then
      svn up $BASHGEMS_HOME/gems/$update
    fi
    if [[ -z "$update"  ]]
    then
      find $BASHGEMS_HOME/gems/ -type d -maxdepth 1  |xargs svn up 
    fi

    #bgem -list
    if [[  "$list" != _  ]]
    then
      if [[ "$remote" != _ ]]
      then
        for s in $GEMS_SITE
        do
          svn list $s
        done
      else
        find $BASHGEMS_HOME/gems/ -type d -maxdepth 1
      fi
    fi
    #bgem -load cpptest
    #bgem -load app/iknow/.init.sh
    if [[ -n "$load" ]]
    then
      [[ -f $BASHGEMS_HOME/gems/$load/$load.sh ]] && . $BASHGEMS_HOME/gems/$load/$load.sh
      [[ -f $BASHGEMS_HOME/gems/$load/.bgem ]] && . $BASHGEMS_HOME/gems/$load/.bgem
    fi
    if [[ -n "$use" ]]
    then
      bgem -install $use
      bgem -load $use
    fi

    if [[ -n "$info" ]]
    then
      svn log $BASHGEMS_HOME/gems/$info
    fi
    if [[  "$publish" != _ && "$m" != _ ]]
    then
      cd $publish && cd $OLDPWD || { echo "Error $publish , is it write?";return; }
      gem_name=`echo $OLDPWD|awk -F/ '{print $NF}'`
      echo "run this commond to publish"
      echo svn import $publish "$GEMS_SITE/$gem_name" -m \"$m\"
    fi
  else
    echo '
    bgem -list
    bgem -install btest
    bgem -uninstall btest
    bgem -source http://www.git.com
    '
  fi
}

bashgem()
{
  bgem "$@"
}

bgem_init()
{
  logo
  echo "TesterHome: https://testerhome.com"
  echo "TTF: https://testerhome.com/topics/15522"
  echo "BashGems: https://github.com/seveniruby/bashgems.git"
  [ -f $BASHGEMS_HOME/lib/shellex.sh ] && . $BASHGEMS_HOME/bashgem/lib/shellex.sh
  #[[ -d $BASHGEMS_HOME/gems/ruby ]] && bgem -load ruby
  :
}

#########################
[[ -z "$BASHGEMS_HOME" ]] && export BASHGEMS_HOME=~/.bashgems
#export BASHGEMS_SITE=https://sihanjishu.googlecode.com/svn/trunk/bashgems/
export GEMS_SITE='https://svn.baidu.com/app-test/search/sep/trunk/bashgems/gems/'
export BASHGEM_SITE='https://svn.baidu.com/app-test/search/sep/trunk/bashgems/bashgem'
bgem_init "$@"
:
