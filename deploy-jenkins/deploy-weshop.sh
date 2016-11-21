#!/bin/bash
#
#the script of auto deploy

export JAVA_HOME=/usr/local/jdk  
#export JAVA_BIN=/usr/java/jdk1.6.0_45/bin  
export PATH=$PATH:$JAVA_HOME/bin

#defined variables

PROJECT=weshop



#backup the project

time_dir=`date '+%Y%m%d%H%M'`
[ -d /data/webapps ] && mkdir -p /data/backup/${time_dir} && cd /data/webapps/ && tar zcf /data/backup/${time_dir}/$PROJECT.tar.gz $PROJECT

#back up the file of config
#for i in $CONF;do
#  cp /data/webapps/$PROJECT/WEB-INF/classes/$i /data/backup/conf/
#done

#stop the project

#cd /data/dubbo/$PROJECT/bin/ && ./stop.sh

#if [ `ps -ef|grep java|grep -v grep|wc -l` -ne 0 ];then
#	kill -9 $(ps -aef | grep java | grep -v grep | awk '{print $2}')
#fi

#remove old project

rm -rf /data/webapps/$PROJECT

#deploy the tar.gz

cd /home/tomcat/ && tar xf weshop.tar.gz -C /data/webapps/
rm -rf /home/tomcat/weshop.tar.gz
#rm -rf /home/dubbo/$PROJECT*
#echo "*********clean up the work dierctory************"
#rm -rf /data/project/settlment/work/*

#restore the conf
#cp /data/backup/conf/* /data/webapps/$PROJECT/WEB-INF/classes/

#start the project

#cd /data/dubbo/$PROJECT/bin/ && ./startup.sh
