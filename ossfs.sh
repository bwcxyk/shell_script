#!/bin/bash

# 配置阿里云OSS信息
OSS_BUCKET="backup"
OSS_MOUNT_POINT="/data/oss"
OSS_ENDPOINT="http://oss-cn-shanghai.aliyuncs.com"

# 检查是否已经挂载
if grep -qs "$OSS_MOUNT_POINT" /proc/mounts; then
    echo "OSSFS已经挂载在$OSS_MOUNT_POINT"
else
    echo "挂载OSSFS到$OSS_MOUNT_POINT"
    ossfs "$OSS_BUCKET" "$OSS_MOUNT_POINT" -ourl="$OSS_ENDPOINT"
    
    if [ $? -eq 0 ]; then
        echo "成功挂载OSSFS到$OSS_MOUNT_POINT"
    else
        echo "挂载OSSFS失败"
    fi
fi