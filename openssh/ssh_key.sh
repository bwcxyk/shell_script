#!/usr/bin/env bash

# author YaoKun
# date 2021年3月1日13:14:36

. /etc/init.d/functions

# 测试输出
#cat hosts.txt | \
#while read ipaddr port user passwd;
#do
#echo ${passwd}
#echo ${user}
#echo ${ipaddr}
#echo ${port};
#done

# 分发公钥
# 检查 hosts.txt 是否存在
if [ ! -f hosts.txt ]; then
    echo "错误：hosts.txt 文件不存在。"
    exit 1
fi
# 开始读取 hosts.txt 中的每一行
while IFS=' ' read -r ipaddr port user passwd; do
    # 使用 sshpass 进行密码传递，并使用 ssh-copy-id 复制公钥
    echo "正在向 ${user}@${ipaddr}:${port} 复制公钥..."

    if sshpass -p "${passwd}" ssh-copy-id -p "${port}" "${user}"@"${ipaddr}" -i ~/.ssh/id_rsa.pub -o StrictHostKeyChecking=no; then
        echo "公钥复制成功。"
    else
        echo "公钥复制失败，请检查错误信息。"
    fi

done < hosts.txt
