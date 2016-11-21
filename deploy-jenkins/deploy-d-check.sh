#!/bin/bash
#
#the script of auto deploy

export JAVA_HOME=/usr/local/jdk  
#export JAVA_BIN=/usr/java/jdk1.6.0_45/bin  
export PATH=$PATH:$JAVA_HOME/bin

#defined variables

PROJECT=dock_service



#backup the project

time_dir=`date '+%Y%m%d%H%M'`
[ -d /data/dubbo ] && mkdir -p /data/backup/${time_dir} && cd /data/dubbo/ && tar zcf /data/backup/${time_dir}/$PROJECT.tar.gz $PROJECT

#back up the file of config
#for i in $CONF;do
cp /data/dubbo/$PROJECT/conf/logback.xml /data/backup/conf/
cp /data/dubbo/$PROJECT/bin/startup.sh /data/backup/sh/
#done

#stop the project

cd /data/dubbo/$PROJECT/bin/ && ./stop.sh

#if [ `ps -ef|grep java|grep -v grep|wc -l` -ne 0 ];then
#	kill -9 $(ps -aef | grep java | grep -v grep | awk '{print $2}')
#fi

#remove old project

rm -rf /data/dubbo/$PROJECT/*

#deploy the tar.gz

cd /home/dubbo/ && tar xf pzj.service.dock-1.1.0-SNAPSHOT.tar.gz && cd /home/dubbo/pzj.service.dock-1.1.0-SNAPSHOT/ && cp -R ./* /data/dubbo/$PROJECT/
rm -rf /home/dubbo/*dock*
#echo "*********clean up the work dierctory************"
#rm -rf /data/project/settlment/work/*

#restore the conf
cp /data/backup/conf/* /data/dubbo/$PROJECT/conf/
cp /data/backup/sh/* /data/dubbo/$PROJECT/bin/
#start the project

cd /data/dubbo/$PROJECT/bin/ && ./startup.sh



##############
while true;do
   sleep 1
   check=`netstat -tlnp | grep java | grep 20[0-9][0-9][0-9]`
   [[ -n $check ]] && netstat -tlnp && exit 0
done



