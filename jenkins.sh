#!/bin/bash

export JENKINS_HOME="/data/jenkins"

####################################
# @description jenkins运行脚本
# @params $? => 代表上一个命令执行后的退出状态: 0->成功,1->失败
#         $1 => 脚本第一个参数-操作类型(start|stop|restart)
# @example => sh jenkins.sh start
# @author yaokun
# @date 2021/11/24 10:59
####################################


# 在执行过程中若遇到使用了未定义的变量或命令返回值为非零，将直接报错退出
set -eu

# 检查参数个数
if [ "${#}" -lt 1 ]; then
	echo -e "\033[41;37m 脚本使用示例: jenkins start|stop|restart  \033[0m"
	exit
fi

# 获取脚本第一个参数
APP_OPT=${1}
# 端口
APP_PORT=8080
# 名称
APP_NAME=jenkins
# jar名 | war名
APP=${APP_NAME}.war
# 程序根目录
APP_HOME=/usr/local/jenkins
# 数据目录
# export JENKINS_HOME=/data/jenkins
# 日志名
APP_LOG_NAME=jenkins
# 日志根目录
APP_LOG_HOME=/usr/local/jenkins
# 程序运行参数
# Jenkins Parameters：https://www.jenkins.io/doc/book/installing/initial-settings/
# Jenkins properties：https://www.jenkins.io/doc/book/managing/system-properties/

JENKINS_OPTS="--httpPort=${APP_PORT} --prefix=/jenkins --sessionTimeout=480 --sessionEviction=14400"
JAVA_OPTS="-Xmx800M -Xms800M -XX:+UseG1GC -XX:+UseStringDeduplication -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/tmp/ -Duser.timezone=Asia/Shanghai -Dhudson.security.csrf.GlobalCrumbIssuerConfiguration.DISABLE_CSRF_PROTECTION=true -Dorg.jenkinsci.plugins.durabletask.BourneShellScript.LAUNCH_DIAGNOSTICS=true"

echo "本次操作服务名：[${APP_NAME}]"
echo "本次操作选择：[${APP_OPT}]"

# 停止
function stop(){
  echo "<-------------------------------------->"
  echo "[${APP_NAME}] ... stop ..."
  # 查看该jar进程
  pid=`ps -ef | grep ${APP} | grep -v 'grep' | awk '{print $2}'`
  echo "[${APP_NAME}] pid="${pid}
  # 存在则kill,不存在打印一下吧
  if [ "${pid}" ]; then
    kill -9 ${pid}
      # 检查kill是否成功
      if [ "$?" -eq 0 ]; then
          echo "[${APP_NAME}] stop success"
      else
          echo "[${APP_NAME}] stop fail"
      fi
  else
    echo "[${APP_NAME}] 进程不存在"
  fi
}


# 运行
function start(){
  echo "<-------------------------------------->"
  echo "[${APP_NAME}] ... start ..."
  cd ${APP_HOME}
  echo "当前路径:`pwd`"
  # 赋予可读可写可执行权限
  # chmod 777 ${APP}
  echo "启动命令: nohup java ${JAVA_OPTS} -jar ${APP_HOME}/${APP} ${JENKINS_OPTS} > ${APP_LOG_HOME}/${APP_NAME}.log 2>&1 &"
  nohup java ${JAVA_OPTS} -jar ${APP_HOME}/${APP} ${JENKINS_OPTS} > ${APP_LOG_HOME}/${APP_NAME}.log 2>&1 &
  if [ "$?" -eq 0 ]; then
    echo "[${APP_NAME}] start success"
  else
    echo "[${APP_NAME}] start fail"
  fi
}


# 重启
function restart(){
  echo "<-------------------------------------->"
  echo "[${APP_NAME}] ... restart ..."
	stop
	start
}


# 多分支条件判断执行参数
case "${APP_OPT}" in
	"stop")
		stop
		;;
	"start")
		start
		;;
	"restart")
		restart
		;;
	*)
	echo -e "\033[41;37m 提示:不支持参数 命令 -> ${APP_OPT} \033[0m"
	;;
esac
