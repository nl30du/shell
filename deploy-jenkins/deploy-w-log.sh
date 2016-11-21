#!/bin/bash
#
#the script of auto deploy

#Defined variables

CONF="dubbo.properties  jdbc.properties  logback.xml  system.properties"

if [ -d /data/webapps/ ];then
  START_PATH=`find /data/webapps/ -type d -name "WEB-INF"| sed 's@\(.*\)WEB-INF@\1@g'`
  PROJECT=`echo $START_PATH | awk -F/ '{print $4}'`
#echo "$START_PATH"
 # CONF_PATH=${START_PATH}WEB-INF/classes
elif [ -d /data/dubbo/ ];then
  START_PATH=`find /data/dubbo/ -type d -name "conf" | sed 's@\(.*\)conf@\1@g'`
  PROJECT=`echo $START_PATH | awk -F/ '{print $4}'`
fi

#backup the project

time_dir=`date '+%Y%m%d%H%M'`
[ -d /data/webapps ] && mkdir -p /data/backup/${time_dir} && cd /data/webapps/ && tar zcfv /data/backup/${time_dir}/$PROJECT.tar.gz $PROJECT

#back up the file of config
for i in $CONF;do
  cp /data/webapps/$PROJECT/WEB-INF/classes/$i /data/backup/conf/
done

#stop the project

/etc/init.d/tomcat stop
#if [ `ps -ef|grep java|grep -v grep|wc -l` -ne 0 ];then
#	kill -9 $(ps -aef | grep java | grep -v grep | awk '{print $2}')
#fi

#remove old project

rm -rf /data/webapps/$PROJECT/*

#deploy the war.

mv /home/tomcat/appapi.war  /data/webapps/$PROJECT/appapi.zip && cd /data/webapps/$PROJECT/ && unzip appapi.zip  &> /dev/null && chown -R tomcat.tomcat ./*

rm -rf /data/webapps/$PROJECT/appapi.zip
#echo "*********clean up the work dierctory************"
rm -rf /data/project/$PROJECT/work/*

#restore the conf
cp /data/backup/conf/* /data/webapps/$PROJECT/WEB-INF/classes/

#start the project
[[ -f /home/tomcat/check.log ]] && > /home/tomcat/check.log && touch /home/tomcat/check.log
[[ -f /home/tomcat/ktail.sh ]] && rm -rf /home/tomcat/ktail.sh
cat >/home/tomcat/ktail.sh<<EOF
#!/bin/bash
while true;do
   sleep 1
   grep "Server startup in" /home/tomcat/check.log &> /dev/null
   [[ \$? -eq 0 ]] && pkill tail && exit 0
done
EOF

bash /home/tomcat/ktail.sh &

/etc/init.d/tomcat start && sleep 1 && tail -f /data/logs/catalina.out | tee /home/tomcat/check.log

sleep 1
rm -rf /home/tomcat/{check.log,ktail.sh}
echo "the deploy is done."









##
#!/bin/bash
while true;do
   sleep 1
   check=`netstat -tlnp | grep java | grep 20[0-9][0-9][0-9]`
   [[ -n $check ]] && netstat -tlnp && exit 0
done


##