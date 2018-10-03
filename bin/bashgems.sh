#!/usr/bin/env bash

# ARGS="install list" pp "$@"
pp() {
	local key i count=$#
	if [ -z "$ARGS" ]; then
		echo you should use ARGS=\"x y long\" pp to parse parameters
		return 1
	fi
	ARGS="help $ARGS"
	for ((i = 0; i < count; i++)); do
		[ -z "$1" ] && shift && continue
		for p in $ARGS; do
			if [ "$1" = "$p" -o "$1" = "-$p" -o "$1" = "--$p" ]; then
				if [ -n "$2" ]; then
					eval "$p=\"${2//\"/\\\"}\"" #unset the var and set value to it
				else
					eval "$p=true" #unset the var and set value to it
				fi
			fi
		done
		shift
	done

	if [ "$help" = "true" ]; then
		echo "${FUNCNAME[1]}() need set parameters"
		for p in $ARGS; do
			eval echo $p=\${$p}
		done
		echo
	fi
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
