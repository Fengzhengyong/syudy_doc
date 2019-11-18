#!/bin/bash

SERVERS="172.20.177.197 172.20.177.198 172.20.177.199"
PASSWORD=kingdee


auto_ssh_copy_id() {
    expect -c "set timeout -1;
        spawn ssh-copy-id $1;
        expect {
            *(yes/no)* {send -- yes\r;exp_continue;}
            *assword:* {send -- $2\r;exp_continue;}
            eof        {exit 0;}
        }";
}

ssh_copy_id_to_all() {
    for SERVER in $SERVERS
    do
        auto_ssh_copy_id $SERVER $PASSWORD
    done
}

ssh_copy_id_to_all
# 将 install.sh 传到每个节点
for SERVER in $SERVERS
do
    scp test.sh root@$SERVER:/kingdee
    ssh root@$SERVER /kingdee/test.sh
done