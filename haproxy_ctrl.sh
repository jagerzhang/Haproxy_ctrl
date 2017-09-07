#!/bin/bash
###################################################################
#  Haproxy Service Script 1.0.0 Author: Jager <ge@zhangge.net>    #
#  Common Operations(start|stop|restart|mon|test)                 #
#-----------------------------------------------------------------#
#  For more information please visit http://zhangge.net/5125.html #
#  Copyright @2017 zhangge.net. All rights reserved.              #
###################################################################
# chkconfig: 35 10 90 
export PATH=/sbin:/usr/sbin:/usr/local/sbin:/usr/local/bin:/usr/bin:/bin:$PATH
PROCESS_NAME=haproxy
BASE_DIR=/usr/local/haproxy
EXEC=$BASE_DIR/sbin/haproxy
PID_FILE=$BASE_DIR/logs/haproxy.pid
DEFAULT_CONF=$BASE_DIR/conf/haproxy.cfg
MONLOG_PATH="$BASE_DIR/logs/${PROCESS_NAME}_mon.log"

# COLOR print
COLOR_RED=$(    echo -e "\e[31;49m" ) 
COLOR_GREEN=$(  echo -e "\e[32;49m" )
COLOR_RESET=$(  echo -e "\e[0m"     )
info() { echo "${COLOR_GREEN}$*${COLOR_RESET}"   ;}
warn() { echo "${COLOR_RED}$*${COLOR_RESET}"     ;}

do_log()
{
    local log_fpath=$1
    local log_content=$2
    echo "$(date '+%F %T') $log_content" >> $log_fpath
}

print_usage()
{
    echo
    info " Usage: $(basename $0) [start|stop|restart|mon|test]"
    echo 
}

#get Expanding configuration
ext_configs()
{
    CONFIGS=
    if [[ -d $BASE_DIR/conf/enabled ]];then
        for FILE in $(find $BASE_DIR/conf/enabled -type l | sort -n)
        do
                CONFIGS="$CONFIGS -f $FILE";
        done
        echo $CONFIGS
    else
        echo
    fi
}
# check process status
check_process()
{
    PID=`get_pid`
    if ps aux | awk '{print $2}' | grep -qw $PID 2>/dev/null ;then
        true
    else
        false
    fi
    
}
# check Configuration file
check_conf()
{
    $EXEC -c -f $DEFAULT_CONF `ext_configs` >/dev/null
    return $?
}
get_pid()
{
    if [[ -f $PID_FILE ]];then
        cat $PID_FILE
        else
            warn " $PID_FILE not found!"
                exit 1
        fi
}
start()
{
    echo
    if check_process;then
        warn " ${PROCESS_NAME} is already running!"
    else
        $EXEC -f $DEFAULT_CONF `ext_configs` && \
        echo -e " ${PROCESS_NAME} start                        [ `info OK` ]" || \
        echo -e " ${PROCESS_NAME} start                        [ `warn Failed` ]" 
    fi
    echo
}

stop()
{
    echo
    if check_process;then
        PID=`get_pid`
        kill -9 $PID >/dev/null 2>&1
        echo -e " ${PROCESS_NAME} stop                         [ `info OK` ]"
    else
        warn " ${PROCESS_NAME} is not running!"
    fi
    echo
}

restart()
{
    echo
    if check_process;then
        :
    else
        warn " ${PROCESS_NAME} is not running! Starting Now..."
    fi
    if `check_conf`;then
        PID=`get_pid`
        $EXEC -f $DEFAULT_CONF `ext_configs` -st $PID && \
        echo -e " ${PROCESS_NAME} restart                      [ `info OK` ]" || \
        echo -e " ${PROCESS_NAME} restart                      [ `warn Failed` ]" 
    else
        warn " ${PROCESS_NAME} Configuration file is not valid, plz check!"
        echo -e " ${PROCESS_NAME} restart                      [ `warn Failed` ]"
    fi
    echo
}

mon()
{
    if check_process;then
        info "${PROCESS_NAME} is running OK!"
        do_log $MONLOG_PATH "${PROCESS_NAME} is running OK!"
    else
        start
        warn " ${PROCESS_NAME} not running, start it!"
        do_log $MONLOG_PATH "${PROCESS_NAME} not running, plz check"
    fi
}

if [[ $# != 1 ]]; then
    print_usage
    exit 1
else
    case $1 in
        "start"|"START")
            start
        ;;
        "stop"|"STOP")
            stop
        ;;
        "restart"|"RESTART"|"-r")
            restart
        ;;
        "status"|"STATUS")
            if check_process;then
                info "${PROCESS_NAME} is running OK!"
            else
                warn " ${PROCESS_NAME} not running, plz check"
            fi
        ;;
        "test"|"TEST"|"-t")
            echo
            if check_conf ;then
                info " Configuration file test Successfully."
            else
                warn " Configuration file test failed."
            fi
            echo
        ;;
        "mon"|"MON"|"-m")
            mon
        ;;
        *)
        print_usage
        exit 1
    esac
fi
