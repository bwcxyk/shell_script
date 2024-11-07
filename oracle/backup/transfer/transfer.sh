#!/bin/bash
# with file transfer and data import
# set -ex  # 启用调试模式，查看命令执行过程，便于排错

# shellcheck source=/dev/null
source /home/oracle/.bash_profile
date=$(date +'%Y%m%d')0300        # 当前日期加上固定后缀 "0300"
user="username"
passwd="password"
application="tms"
directory="DATA_PUMP_DIR2"         # Oracle 数据泵目录
remote_dir="/data/oracle/admin/orcl/dpdump"  # 远程服务器上的数据目录
directory_dir="/volumes/data/backup/dpdump"  # 本地存放下载文件的目录

function download() {
    cd "${directory_dir}" || { echo "无法进入目录 ${directory_dir}"; exit 1; }
    if scp oracle@172.19.180.0:"${remote_dir}"/"${application}"_"${date}"*.dmp .
    then
        echo -e "\033[34;1m下载成功  \033[0m"
        echo
        echo -e "\033[33;1m文件存放路径：${directory_dir} \033[0m" && ls -lh ${directory_dir}/
    else
        echo -e "\033[33;1m下载失败，请根据报错信息进行解决，再重试 \033[0m"
        exit
    fi
}

# 导入操作
function data_import() {
    if impdp "${user}"/"${passwd}" \
        directory="${directory}" \
        parallel=3 \
        dumpfile="${application}"_"${date}"_%U.dmp \
        remap_tablespace=tms:tms_temp \
        remap_schema=tms_user:tms_temp_user \
        table_exists_action=replace \
        transform=segment_attributes:n
    then
        echo -e "\033[34;1m导入成功 \033[0m"
    else
        echo -e "\033[33;1m导入异常 \033[0m"
        #exit
    fi
}

# 清理临时文件
function delete() {
    echo "开始删除临时文件"
    cd "${directory_dir}" || { echo "无法进入目录 ${directory_dir}"; exit 1; }
    rm -fv "${application}"_"${date}"*.dmp
    echo "删除完成"
}

function main() {
    download
    data_import
    delete
}

main
