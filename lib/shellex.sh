defineY() {
    set | grep "^$1="
}

: <<sss_help
class:cmd
sss  #enter a screen with color promotion
sss -u dinglh
sss -s session_name
sss_help
exscreen() {
    local s
    ARGS="tmp s" pp "$@"

    echo -e '
	multiuser on
	hardstatus on
	hardstatus alwayslastline
	defencoding UTF-8
	encoding UTF-8 GBK
	hardstatus string "%{= kG}%-w%{.cW}%n %t%{-}%+w %=%{= kG} %H %{..Y} %Y/%m/%d %c"
	logfile '"/tmp/${USER}_${s:=$USER}.log"'
    ' >$tmp
    echo session_name=$s
    screen -ArxRL ${s:=$USER} -c $tmp -t ${s:=$USER}
}
screen_ex() {
    exscreen "$@"
}
ps_ex() {
    ps -o uname,pid,ppid,thcount,ni,pri,psr,pcpu,pmem,rss,vsz,sz,start_time,time,comm,c,command "$@"
}

parallel() {
    [ $# -lt 2 ] && ls | echo parallel 10 "echo $index" && return
    local p=$1
    shift
    local cmd="$@"
    echo cmd="$cmd"
    echo parallel=$p
    while true; do
        local count=$(jobs -l | grep Running | wc -l)
        echo running count=$count
        if ((count >= p)); then
            sleep 1
        else
            echo "run $cmd"
            eval $cmd &
        fi
    done
}

#key=2 value=1 include="a c" exclude="b" include_and_exclude
include_and_exclude() {
    local sep
    local key
    local value
    local include
    local exclude
    awk -v sep="$sep" \
        -v key="$key" \
        -v value="$value" \
        -v include_keys="$include" \
        -v exclude_keys="$exclude" \
        '
        BEGIN{
            if(sep!="") FS=sep
            if(key=="") key=0
            if(value=="") value=key
            include_count=split(include_keys,include_list," "); 
            exclude_count=split(exclude_keys,exclude_list," ");            
        }
        {
            if(include_count==0){
                if( $0~include_list[i] && black[$key]!=1 ) 
                    {s[$key]=$value}
            }else{
                for(i=1;i<=include_count;i++)
                    if( $0~include_list[i] && black[$key]!=1 ) 
                        {s[$key]=$value}
            }
        }
        {
            for(i=1;i<=exclude_count;i++) if( $0~exclude_list[i]) {black[$key]=1; delete s[$key]}
        }
        END{
            for(k in s) print k, s[k]
        }
    '
}

#f(){ eval local x=$(get_temp_file 2 m 3  ); echo $x; }
get_temp_file() {
    local t

    local r
    for p in "$@"; do
        [ "$p" = "%S" ] && p=$(date +%Y-%m-%dT%H:%M:%S)
        [ "$p" = "%M" ] && p=$(date +%Y-%m-%dT%H:%M)
        [ "$p" = "%H" ] && p=$(date +%Y-%m-%dT%H)
        [ "$p" = "%d" ] && p=$(date +%Y-%m-%d)

        r=$r.$p
    done
    echo "/tmp/\$FUNCNAME$r"
}


#f(){ local log=$(log_file %M) }
log_file() {
    local r
    for p in "$@"; do
        [ "$p" = "%S" ] && p=$(date +%Y-%m-%dT%H:%M:%S)
        [ "$p" = "%M" ] && p=$(date +%Y-%m-%dT%H:%M)
        [ "$p" = "%H" ] && p=$(date +%Y-%m-%dT%H)
        [ "$p" = "%d" ] && p=$(date +%Y-%m-%d)

        r=$r.$p
    done
    caller 0 | awk -v t="$r" '{print $NF"."$(NF-1)t".log"}'
}

test_log_file(){
    local log=$(log_file %M)
    echo log=$log
}




#python dict for shell
#dict a 1
#dict a
#key=a dict
#key=a value=1 dict
dict() {
    local key k
    local value v
    [ -z "$key" ] && key="$k"
    [ -z "$value" ] && value="$v"
    [ -z "$key" ] && key="$1"
    [ -z "$value" ] && value="$2"

    for i in ${!_ArrayKeyGlobal[@]}; do
        if [ "${_ArrayKeyGlobal[i]}" = "$key" ]; then
            if [ -n "$value" ]; then
                #overwrite
                _ArrayValueGlobal[i]="$value"
            elif [ -z "$value" ]; then
                #get
                echo "${_ArrayValueGlobal[i]}"
            fi
            return
        fi
    done
    #new
    if [ -n "$value" ]; then
        #put
        _ArrayKeyGlobal+=("$key")
        _ArrayValueGlobal+=("$value")
        return
    elif [ -z "$value" ]; then
        #not exist
        return 1
    fi

}

test_dict() {
    unset _ArrayKeyGlobal _ArrayValueGlobal
    dict a 1
    dict b "2 3"
    [ "$(dict a)" = 1 ] || echo error
    [ "$(dict b)" = "2 3" ] || echo error

    k=a v=1 dict
    k=b v="2 3" dict
    [ "$(dict a)" = 1 ] || echo error
    [ "$(dict b)" = "2 3" ] || echo error

    key=a value=1 dict
    key=b value="2 3" dict
    [ "$(dict a)" = 1 ] || echo error
    [ "$(dict b)" = "2 3" ] || echo error

    dict c && echo error

}

#set and get return value
# seveniruby:~ seveniruby$ f(){
# > echo 1 2
# > return_value 3 4
# > }
# seveniruby:~ seveniruby$ f
# 1 2
# seveniruby:~ seveniruby$ return_value
# 3 4
return_value(){
    [ $# -ge 1 ] && _RETURN_VALUE="$@" || echo $_RETURN_VALUE
}


#timestamp 2020-04-16
#format="%Y-%m-%d" timestamp  -1d
timestamp() {
    local format
    [ -z "$format" ] && format="%s"

    local param="${@:-+0}"
    local result

    #depend gawk
    if echo "$param" | grep '^[+-]' >/dev/null; then
        result=$(awk -v diff=$(echo "0$param" | sed 's#d#*3600*24#' | bc) 'BEGIN{print systime()+diff}')
    else
        result=$(echo "$param" | awk -F ' |-|:' '{for(i=1;i<=6;i++) {if($i=="") $i="00";s=s$i" "};print mktime(s)}')
    fi
    if [ -n "$format" ]; then
        awk -v result="$result" -v format="$format" 'BEGIN{print strftime(format, result)}'
    else
        echo "$result"
    fi
}


#echo '{"a": 1, "b": [3,4]}' | json_parse "j=json.loads(sys.stdin.read());print(j['b'])"
json_parse(){
    python -c 'import sys; import os; import json;'"$@"
}