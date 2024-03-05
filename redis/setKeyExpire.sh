#!/bin/bash

# 设置数据库连接信息
db_ip="127.0.0.1"
db_port="6379"
password="redis"

# 定义要查找的关键字
keyword="P*signTime"

# 定义日志文件路径
log_file="redis_key_expiry.log"

# 清空日志文件
cat /dev/null > "$log_file"

# 使用 SCAN 命令迭代遍历匹配的 key
while IFS="" read -r key; do
    # 检查键的剩余过期时间，并将输出重定向到 /dev/null
    ttl=$(redis-cli -h "$db_ip" -p "$db_port" -a "$password" ttl "$key" 2>/dev/null)
    if [[ $ttl -eq -1 ]]; then
        # 生成随机过期时间
        time=$(tr -cd '1-9' </dev/urandom | head -c 5)
        # 设置 key 的过期时间
        redis-cli -h "$db_ip" -p "$db_port" -a "$password" expire "$key" "$time" >/dev/null 2>&1
        # 记录操作到日志文件
        echo "$(date +"%Y-%m-%d %T") - Set expiry for key $key to $time seconds" >> "$log_file"
    else
        echo "$(date +"%Y-%m-%d %T") - Key $key has ttl $ttl seconds" >> "$log_file"
    fi
done < <(redis-cli -h "$db_ip" -p "$db_port" -a "$password" --raw scan 0 match "$keyword" count 1000)
