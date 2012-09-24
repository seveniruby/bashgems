tmp=/tmp/${USER}_tmp


defineY()
{
	set |grep "^$1="
}

:<<seven_getopt_help
class:basic
user:yansheng.huangys
date:200910302209
cat:bash
seven_getopt -p 1 -s 2 -d 
then the result is 
p=1 s=2 d=""
so you can use it in your functions for parameters parsing
seven_getopt_help
seven_getopt()
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


:<<sss_help
class:cmd
sss  #enter a screen with color promotion
sss -u dinglh
sss -s session_name
sss_help
exscreen()
{
	local s
	pp "$@"

	echo -e '
	multiuser on
	hardstatus on
	hardstatus alwayslastline 
	defencoding UTF-8
	encoding UTF-8 GBK
	hardstatus string "%{= kG}%-w%{.cW}%n %t%{-}%+w %=%{= kG} %H %{..Y} %Y/%m/%d %c"
	logfile '"/tmp/${USER}_${s:=$USER}.log"'	
	' > $tmp
	echo session_name=$s
	screen -ArxRL ${s:=$USER} -c $tmp -t ${s:=$USER}
}
screen_ex()
{
	exscreen "$@"
}
ps_ex()
{
        ps -o uname,pid,ppid,thcount,ni,pri,psr,pcpu,pmem,rss,vsz,sz,start_time,time,comm,c,command "$@"
}






