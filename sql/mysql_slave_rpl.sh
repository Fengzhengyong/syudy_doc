#!/bin/sh

master_ip=$1
slave_ip=$2

mstool="mysql -unext -pkingdee2019 -h $master_ip --port=3306 mysql"
sltool="mysql -unext -pkingdee2019 -h $slave_ip --port=3306 mysql"

declare -a slave_stat
slave_stat=($($sltool -e "show slave status\G"|grep Running |awk '{print $2}'))

if [ "${slave_stat[0]}" = "Yes" -a "${slave_stat[1]}" = "Yes" ] 
then
    echo "OK slave is running"
    exit 0
else
    echo
    echo "*********************************************************"
    echo "Now Starting replication with Master Mysql!"
    file=`$mstool -e "show master status\G"|grep "File"|awk '{print $2}'`
    pos=`$mstool -e "show master status\G"|grep "Pos"|awk '{print $2}'`
    $sltool -e "change master to master_host='$master_ip',master_port=3306,master_user='repl',master_password='Kingdee_2019repl',master_log_file='$file',master_log_pos=$pos;start slave;stop slave;start slave;"
    sleep 3
    $sltool -e "show slave status\G;"|grep Running
    echo
    echo "Now Replication is Finished!"
    echo
    echo "**********************************************************"
    exit 2
fi
