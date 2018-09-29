tmp=/tmp/${USER}_tmp


defineY()
{
    set |grep "^$1="
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





