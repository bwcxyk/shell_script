#!/bin/bash

# 函数：添加带有版本号的新标签并推送到远程仓库
function add_new_tag {
    if [ -z "$version" ]; then
        echo "Error: Version number must be provided."
        exit 1
    fi
    git tag -a "$version" -m "version $version"
    git push origin "$version"
}

# 函数：删除三个月前的旧标签
function delete_old_tags {
    # 开始处理删除旧标签
    echo "Starting deletion of old tags..."
    # 获取当前日期的时间戳
    local now=$(date +%s)

    # 计算三个月前的日期的时间戳
    local three_months_ago=$(date -d "-3 months" +%s)

    # 处理标签
    echo ""
    git for-each-ref --format="%(refname:short) %(creatordate:unix)" refs/tags/ | while IFS=' ' read -r tag timestamp; do
        if [ "$timestamp" -lt "$three_months_ago" ]; then
            echo "Deleting tag: $tag"
            git tag -d "$tag"
            git push origin --delete "$tag"
        fi
    done
    # 结束处理删除旧标签
    echo "Finished deletion of old tags."
}

# 主程序入口
if [ "$1" == "add" ]; then
    version="$2"
    add_new_tag
elif [ "$1" == "delete" ]; then
    delete_old_tags
else
    echo "Usage: $0 [add|delete] [version|none]"
    exit 1
fi
