#!/bin/bash

function log::error() {
  # 错误日志
  printf "[%s]: \033[31mERROR:   \033[0m%s\n" "$(date +'%Y-%m-%dT%H:%M:%S.%N%z')" "$*"
}


function log::info() {
  # 基础日志
  printf "[%s]: \033[32mINFO:    \033[0m%s\n" "$(date +'%Y-%m-%dT%H:%M:%S.%N%z')" "$*"
}


function log::warning() {
  # 警告日志
  printf "[%s]: \033[33mWARNING: \033[0m%s\n" "$(date +'%Y-%m-%dT%H:%M:%S.%N%z')" "$*"
}