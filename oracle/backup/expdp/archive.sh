#!/bin/bash
# archive
# author:yaokun

# set -ex

currentDate=$(date +'%Y%m%d')            # 当前日期（精确到天）
currentYearMonth=$(date +'%Y%m')         # 当前年月
application="tms"
db_type='oracle'
backdir="/data/oracle/admin/orcl/dpdump"
archive_dir="/data/ossfs/${application}/${db_type}/${currentYearMonth}"

# 进行tar归档备份文件
function pack_to_tar() {
    if ls ${backdir}/"${application}"_"${currentDate}"*.dmp 1> /dev/null 2>&1
    then
        echo "文件存在，开始归档"
        cd "${backdir}" || { echo "无法进入目录 ${backdir}"; exit 1; }
        tar cf "${application}"_"${currentDate}".tar "${application}"_"${currentDate}"*.dmp
        echo "归档完成"
    else
        echo "未找到备份文件，无法归档"
        exit 1 
    fi
}

# 创建oss中相应文件夹
function mkdir_to_oss() {
    if [ ! -d "${archive_dir}" ]
    then
        echo "目录不存在，正在创建 ${archive_dir}"
        mkdir -p "${archive_dir}" || { echo "目录创建失败 ${archive_dir}"; exit 1; }
    else
        echo "目录 ${archive_dir} 已存在"
    fi
}

# 传输到 oss 存储
function trans_to_oss {
    if ! cp "${application}"_"${currentDate}".tar "${archive_dir}"/
    then
        echo "====传输到 OSS 失败!===="
        exit 1
    else
        echo "====传输到 OSS 成功!===="
    fi
}

# 清理文件
function delete_files {
    echo "开始清理文件"
    cd "${backdir}" || { echo "无法进入目录 ${backdir}"; exit 1; }
    rm -fv "${application}"_"${currentDate}"*.dmp "${application}"_"${currentDate}".tar
    echo "清理完成"
}

function main() {
    pack_to_tar
    mkdir_to_oss
    trans_to_oss
    delete_files
}

main
