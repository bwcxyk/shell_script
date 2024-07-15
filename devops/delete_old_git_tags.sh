#!/bin/bash

# set -x

# 获取当前日期
now=$(date +%s)

# 计算三个月前的日期的时间戳
three_months_ago=$(date -d "-3 months" +%s)

# 获取所有标签和它们的创建日期
git for-each-ref --format="%(refname:short) %(creatordate:unix)" refs/tags/ > tmp_tags.txt

# 遍历临时文件中的标签，删除超过三个月的标签
while IFS=' ' read -r tag timestamp; do
    if [ $timestamp -lt $three_months_ago ]; then
        echo "Deleting tag: $tag"
        git tag -d $tag
        git push origin :refs/tags/$tag
    fi
done < tmp_tags.txt

# 清理临时文件
rm tmp_tags.txt
