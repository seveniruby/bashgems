#!/usr/bin/env bash

#class:basic
#user:yansheng.huangys
#date:200910302209
#cat:bash
# use pp "$@" in your script or function
#pp -p 1 -s 2 -d
#then the result is
#p=1 s=2 d=""
#so you can use it in your functions for parameters parsing
#todo: add help method
pp() {
    local kkk vvv count=$# i
    for ((i = 1; i <= $count; i++)); do
        [ -z "$1" ] && shift && continue
        kkk="${1:1}"
        if [ "${1:0:1}" = '-' -a "$1" == -[a-zA-Z]* ]; then
            eval "$kkk=\"${2//\"/\\\"}\"" #unset the var and set value to it
        fi
        shift
    done
}

bashgems_install() {
    local date=$(date +%Y%m%d)
    [ -d ~/.bashgems ] || mkdir ~/.bashgems
    [ -f /tmp/bashgems_$date.zip ] || wget https://github.com/seveniruby/bashgems/archive/master.zip -O /tmp/bashgems_$date.zip
    if which unzip 2>/dev/null; then
        unzip -o /tmp/bashgems_$date.zip -d /tmp/bashgems_$date
        find /tmp/bashgems_$date/bashgems-master -maxdepth 1 -mindepth 1 -exec cp -rf {} ~/.bashgems/ \;
    elif which git; then
        git clone https://github.com/seveniruby/bashgems.git ~/.bashgems
    else
        echo "you should install unzip or git"
        return 1
    fi
    grep bashgems.sh ~/.bash_profile || echo '[ -f  ~/.bashgems/bin/bashgems.sh ] && . ~/.bashgems/bin/bashgems.sh' >>~/.bash_profile
    . ~/.bash_profile
    [ -n "$BASHGEMS_HOME" ] && echo success
}

logo() {
    echo '
#     __            __            __
#    / /____  _____/ /____  _____/ /_  ____  ____ ___  ___
#   / __/ _ \/ ___/ __/ _ \/ ___/ __ \/ __ \/ __ `__ \/ _ \
#  / /_/  __(__  ) /_/  __/ /  / / / / /_/ / / / / / /  __/
#  \__/\___/____/\__/\___/_/  /_/ /_/\____/_/ /_/ /_/\___/
'
}
bashgems_init() {
    logo
    echo "TesterHome: https://testerhome.com"
    echo "TTF: https://testerhome.com/topics/15522"
    echo "BashGems: https://github.com/seveniruby/bashgems.git"
    echo
    [ -f $BASHGEMS_HOME/lib/shellex.sh ] && . $BASHGEMS_HOME/lib/shellex.sh
    [ -f $BASHGEMS_HOME/lib/hogwarts.sh ] && . $BASHGEMS_HOME/lib/hogwarts.sh
    :
}

#########################
[ -z "$BASHGEMS_HOME" ] && export BASHGEMS_HOME=~/.bashgems
bashgems_init "$@"
:
