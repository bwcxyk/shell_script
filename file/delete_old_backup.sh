#!/bin/bash
# author yao
# for delete old backup
#set -ex

# 定义目录数组
filedirs=(
  "/data/dir1"
  "/data/dir2"
)
# 无二级目录
filedirs2=(
  "/data/dir3"
  "/data/dir4"
)


# 定义日期
olddate=$(date -d '-7 months 1 day' +%Y%m)

# 循环目录数组
for dir in "${filedirs[@]}"
do
  # 获取子目录列表
  subdirs=("${dir}"/*)

  # 循环子目录列表
  for subdir in "${subdirs[@]}"
  do
    # 检查当前子目录是否存在旧文件
    old_file="${subdir}/${olddate}"
    if [ -d "${old_file}" ]; then
      echo "Delete file: ${old_file}"
      rm -rvf "${old_file}"
    fi
  done
done

# 循环目录数组
for dir in "${filedirs2[@]}"
do
  # 检查当前子目录是否存在旧文件
  old_file="${dir}/${olddate}"
  if [ -d "${old_file}" ]; then
    echo "Delete file: ${old_file}"
    rm -rvf "${old_file}"
  fi
done