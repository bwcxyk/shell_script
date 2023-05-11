#!/bin/bash

# 处理单行命令的颜色输出
function black(){
    echo -e "\e[1;30m$1\e[0m"
}
function red(){
    echo -e "\e[1;31m$1\e[0m"
}
function green(){
    echo -e "\e[1;32m$1\e[0m"
}
function yellow(){
    echo -e "\e[1;33m$1\e[0m"
}
function blue(){
    echo -e "\e[1;34m$1\e[0m"
}
function carmine(){
    echo -e "\e[1;35m$1\e[0m"
}
function cyan(){
    echo -e "\e[1;36m$1\e[0m"
}
function white(){
    echo -e "\e[1;37m$1\e[0m"
}

