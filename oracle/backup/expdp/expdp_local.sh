#!/bin/bash
##auth expdp

#set -ex

# shellcheck source=/dev/null
source /home/oracle/.bash_profile
date=$(date +'%Y%m%d%H%M')
user="username"
passwd="password"
directory="DATA_PUMP_DIR2"
olddate=$(date -d yesterday +'%Y%m%d')
backdir="/data/backup/dpdump"

function backup {
    if expdp ${user}/${passwd} \
        directory=${directory} \
        schemas=${user} \
        EXCLUDE=statistics \
        EXCLUDE=TABLE:\"= \'SYSTEM_LOG\'\" \
        filesize=2048M \
        parallel=2 \
        dumpfile=tms_"${date}"_%U.dmp \
        compression=all
    then
        echo -e "\033[34;1m导出成功  \033[0m"
    else
        echo -e "\033[33;1m导出失败 \033[0m"
        exit
    fi
}

function del_old {
    echo "start delete"
    cd ${backdir} || exit
    rm -fv tms_"${olddate}"*.dmp
}

function main {
    backup
    del_old
}

main
