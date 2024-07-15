#!/bin/bash
# 删除旧的tag，保留最近三个月。
# author YaoKun

# 获取当前月份、上个月份和上上个月份的月份代码（格式为YYYYMM）
current_month=$(date +%Y%m)
last_month=$(date -d "1 month ago" +%Y%m)
second_last_month=$(date -d "2 months ago" +%Y%m)

# 将标签名写入临时文件，但排除最近三个月的标签
git tag --list | grep -v "^${current_month}" | grep -v "^${last_month}" | grep -v "^${second_last_month}" > tmp.txt

# 读取临时文件中的每个标签名，并删除远程仓库中的对应标签
while IFS= read -r tag_name; do
    git push origin --delete "$tag_name"
done < tmp.txt

# 清理临时文件
rm -f tmp.txt
