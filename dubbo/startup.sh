#!/bin/sh

LANG=zh_CN
export LANG
CURR_TIME=$(date +%Y-%m-%d-%H-%M-%S)

DEPLOY_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DEPLOY_DIR=`dirname $DEPLOY_DIR`

CONF_DIR=$DEPLOY_DIR/conf
LIB_DIR=$DEPLOY_DIR/lib
LOGS_DIR=$DEPLOY_DIR/logs

if [ ! -d "$LOGS_DIR" ]; then
  mkdir -p "$LOGS_DIR" 
fi

JAVA_OPTS=" -server -Xms2G -Xmx2G -Xss256K -XX:PermSize=128M -XX:MaxPermSize=256M -XX:+UseConcMarkSweepGC -XX:+CMSParallelRemarkEnabled -XX:+UseCMSCompactAtFullCollection -XX:+DisableExplicitGC -XX:+PrintGCDetails -Xloggc:$LOGS_DIR/gc.log -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=$LOGS_DIR/common_service.dump -Djava.net.preferIPv4Stack=true"

LIB_JARS=`ls $LIB_DIR | grep .jar | awk '{print "'$LIB_DIR'/"$0}' | tr "\n" ":"`

java $JAVA_OPTS -classpath $CONF_DIR:$LIB_JARS com.alibaba.dubbo.container.Main $* > $LOGS_DIR/service-$CURR_TIME.log&
