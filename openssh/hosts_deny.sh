#!/bin/env bash

# 把Failed 和Invalid超过5次的写到/etc/hosts.deny中

#cat /var/log/secure|awk '/Invalid/{print $NF} /Failed/{print $(NF-3)}'|sort|uniq -c|awk '{print $2":"$1}' > blacklist
awk '/Failed/{print $(NF-3)}' /var/log/secure | sort | uniq -c | awk '{print $2":"$1}' > blacklist

while IFS=: read -r ip num; do
    if [ "$num" -gt 5 ]; then
        if ! grep -q "$ip" /etc/hosts.deny; then
            echo "sshd:$ip:$num:deny" >> hosts.deny
        fi
    fi
done < blacklist
