#!/bin/bash

# ===== Redis 连接信息 =====
db_ip="127.0.0.1"
db_port="6379"
password="redis"

# ===== 匹配规则 =====
keyword="P*signTime"

# ===== 日志配置 =====
enable_log=true           # 是否开启日志，true开启，false关闭
log_file="redis_key_expiry.log"

# ===== 随机过期时间范围（秒） =====
min_ttl=21600     # 最少 6 小时
max_ttl=86400     # 最多 24 小时

# ===== 清空日志 =====
if $enable_log; then
    : > "$log_file"
fi

# ===== 设置 Redis 密码环境变量（避免泄露） =====
export REDISCLI_AUTH="$password"

# ===== 遍历所有匹配 key =====
cursor=0
expire_cmds_file=$(mktemp)

while :; do
    reply=$(redis-cli -h "$db_ip" -p "$db_port" --raw scan "$cursor" match "$keyword" count 1000)
    cursor=$(echo "$reply" | head -n 1)
    keys=$(echo "$reply" | tail -n +2)

    for key in $keys; do
        ttl_current=$(redis-cli -h "$db_ip" -p "$db_port" ttl "$key" 2>/dev/null)

        if [[ $ttl_current -eq -1 ]]; then
            random_ttl=$((RANDOM % (max_ttl - min_ttl + 1) + min_ttl))
            echo "EXPIRE $key $random_ttl" >> "$expire_cmds_file"
            if $enable_log; then
                echo "$(date +"%Y-%m-%d %T") - Scheduled expire for key '$key' to $random_ttl seconds" >> "$log_file"
            fi
        fi
    done

    [[ "$cursor" == "0" ]] && break
done

# 批量执行 expire 命令，减少网络请求次数
if [[ -s "$expire_cmds_file" ]]; then
    cat "$expire_cmds_file" | redis-cli -h "$db_ip" -p "$db_port" --pipe >/dev/null
fi

rm -f "$expire_cmds_file"
