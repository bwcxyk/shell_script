#!/bin/bash
#mysqldump

date=$(date +%Y%m%d%H%M)
olddate=$(date -d yesterday +'%Y%m%d')
dbuser="root"
dbpasswd="root"
dbname="wms"
backdir="/data/backup"
backfile="wms_${date}.sql.gz"

function backup() {
    echo "开始备份数据库"
    mysqldump -u"${dbuser}" -p"${dbpasswd}" "${dbname}" | gzip > "${backdir}"/"${backfile}"
    echo "备份完成"
}

function del_old {
    echo "开始删除旧备份"
    cd "${backdir}" || exit
    rm -fv wms_"${olddate}"*.sql.gz
    echo "删除完成"
}

function main() {
    backup
    # del_old
}

main
