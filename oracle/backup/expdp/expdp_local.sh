#!/bin/bash
# expdp
# author:yaokun

# set -ex

# shellcheck source=/dev/null
source /home/oracle/.bash_profile
currentTimestamp=$(date +'%Y%m%d%H%M')   # 当前精确到分钟的时间戳
yesterdayDate=$(date -d yesterday +'%Y%m%d')  # 昨天的日期
user='user'
passwd='passwd'
application="tms"
directory="DATA_PUMP_DIR"
backdir="/data/oracle/admin/orcl/dpdump"

function backup {
    if expdp "${user}/${passwd}" \
        directory="${directory}" \
        schemas="${user}" \
        exclude=statistics \
        filesize=2048M \
        parallel=2 \
        dumpfile="${application}"_"${currentTimestamp}"_%U.dmp \
        compression=all
    then
        echo -e "\033[34;1m导出成功  \033[0m"
    else
        echo -e "\033[33;1m导出失败 \033[0m"
        exit
    fi
}

function del_old {
    echo "开始删除昨日备份文件"
    cd "${backdir}" || { echo "无法进入目录 ${backdir}"; exit 1; }
    rm -fv "${application}"_"${yesterdayDate}"*.dmp
    echo "删除完成"
}

function main {
    backup
    del_old
}

main
