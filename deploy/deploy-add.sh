#!/bin/bash
#author:tangcw
#version:2.1

#defined variables

getproject() {
  if [ -d /data/webapps/ ];then
    WEB_START_PATH=`find /data/webapps/ -type d -name "WEB-INF"| sed 's@\(.*\)WEB-INF@\1@g'` 
    WEB_PROJECT=`echo ${WEB_START_PATH} | awk -F/ '{print $(NF-1)}'`
  fi
  if [ -d /data/dubbo/ ];then
    N=0
    DUBBO_PATH_LIST=`find /data/dubbo/ -type d -name "conf" | sed 's@\(.*\)conf@\1@g'`
    #DUBBO_PROJECT_LIST=`echo  | awk -F/ '{print $4}'`
    for i in ${DUBBO_PATH_LIST};do
      dubbo_path_list[$N]="$i"
      dubbo_pro_list[$N]=`echo $i | awk -F/ '{print $(NF-1)}'`
      let N+=1
    done
  fi
  
}

outproject() {
  if [ "$1" -eq 1 ];then
    echo -e "0(web) :${WEB_START_PATH} => \e[1;31m${WEB_PROJECT}(0)\e[0m"
    for((j=0;j<${#dubbo_path_list[*]};j++));do
      let k=j+1
      echo -e "$k(dubbo): ${dubbo_path_list[$j]} => \e[1;31m${dubbo_pro_list[$j]}($k)\e[0m"
    done      
  elif [ "$1" -eq 0 ];then
    for((j=0;j<${#dubbo_path_list[*]};j++));do
      let k=j+1
      echo -e "$k(dubbo): ${dubbo_path_list[$j]} => \e[1;31m${dubbo_pro_list[$j]}($k)\e[0m"
    done
  fi
}

listfunc() {
   check=`echo "$1" | grep ^[0-9]$`
   if [ -z "$check" ];then
      echo "please input the pure number."
      exit 1
   else
      if [ "$2" == "yy" ];then
         if [ "$1" -eq 0 ];then
            #echo "start go web"
            backfunc ${WEB_PROJECT} ${WEB_START_PATH}
            #echo "******************************************************"
            #echo "${WEB_START_PATH}"
            [ "$3" == "deploy" ] && copypackage /home/tangchengwei ${WEB_START_PATH} web
            [ "$3" == "rollback" ] && rollbackpro web && chown -R tomcat.tomcat ${WEB_START_PATH} && restartpro web && exit 0
            #copypackage /home/tangchengwei ${WEB_START_PATH} web
            changeconf web
            restartpro web
         elif [ "$1" -le "$num" ];then
            #echo "start go dubbo($YO)"
            backfunc ${dubbo_pro_list[$1-1]} ${dubbo_path_list[$1-1]} 
            #echo "***************************************************"
            let kk=$1-1
            [ "$3" == "deploy" ] && copypackage /home/tangchengwei ${dubbo_path_list[$1-1]} dubbo $kk
            [ "$3" == "rollback" ] && rollbackpro dubbo && restartpro dubbo $kk && exit 0 
            #copypackage /home/tangchengwei ${dubbo_path_list[$1-1]} dubbo $kk
            changeconf dubbo $kk
            restartpro dubbo $kk
         else
            echo "please input the right number."
         fi
      elif [ "$2" == "ny" ];then
         if [ "$1" -le $num -a "$1" -gt 0 ];then
            #echo "start dubbo($1)"
            backfunc ${dubbo_pro_list[$1-1]} ${dubbo_path_list[$1-1]} 
            #echo "***************************************************"
            let kk=$1-1
            [ "$3" == "deploy" ] && copypackage /home/tangchengwei ${dubbo_path_list[$1-1]} dubbo $kk
            [ "$3" == "rollback" ] && rollbackpro dubbo && restartpro dubbo $kk && exit 0
            #copypackage /home/tangchengwei ${dubbo_path_list[$1-1]} dubbo $kk
            changeconf dubbo $kk
            restartpro dubbo $kk
         else
            echo "please input the right number"
         fi
      fi
   fi
}


#backup function
backfunc() {
   echo -e "######################\e[1;36mbackup the project\e[0m##################################"
   local time_dir=`date '+%Y%m%d%H%M'`
   read -p "Do you want backup the $1(y):" B
   if [ "$B" == "y" ];then 
     local back_path=`echo "$2" | sed 's@\(/.*/\)*.@\1@g'`
     local back_project=`echo "$2" | awk -F/ '{print $(NF-1)}'`
     mkdir -p /data/backup/${time_dir} && cd ${back_path} && tar zcvf /data/backup/${time_dir}/${back_project}.tar.gz ${back_project}
     echo -e "the backup is \e[1;32mdone\e[0m"
   fi  
}
#file exist function
file_exist() {
   EXIST=`find "$1" -name "$2"`
   if [ -n "$EXIST" ];then
      local file_num=`find "$1" -name "$2" | wc -l`
      exist_file_list=`find "$1" -name "$2"`
      exist_file_path=`echo ${exist_file_list} | grep -o "/.*/"`
      [ "${file_num}" -gt 1 ] && of=11 || of=10
   else
      of=00
   fi
}

copypackage() {
  echo -e "##########################\e[1;36mcopy the package\e[0m#############################################"
  [ -f $1/file/*.zip ] && unzip $1/file/*.zip -d $1/file/ &> /dev/null && rm -rf $1/file/*.zip
  [ -f $1/file/*.tar.gz ] && tar xf $1/file/*.tar.gz -C $1/file/ && rm -rf $1/file/*.tar.gz   
  file_list=`ls $1/file/`
  cd $1/file/
  for s in ${file_list};do
     file_exist $2 $s
     if [ "$of" -eq 10 ];then
        cp -R $s ${exist_file_path}
        [ "$?" -eq 0 ] && echo -e "cp the \e[1;34m$s\e[0m to \e[1;34m${exist_file_path}\e[0m is \e[1;32mdone.\e[0m"
        echo ""
     elif [ "$of" -eq 00 ];then
        echo -e "the \e[1;34m$s\e[0m is \e[1;31mnot exist!!!!\e[0m"
        dubbo_no_exist_dest_path="lib conf bin"
        web_no_exist_dest_path="WEB-INF/lib WEB-INF/class"
        if [ "$3" == "dubbo" ];then
           for dd in ${dubbo_no_exist_dest_path};do
              read -p "Please input the path that you want to copy(/data/dubbo/${dubbo_pro_list[$4]}/$dd/):" jdd
              if [ "$jdd" == "y" ];then
                 #judge the conflic jar#
                 local aa=`echo "$s" | grep -o ".*[a-z]-[0-9]\{0,1\}" | sed 's@[0-9]$@*@g'`
                 [ -n "$aa" ] && ls /data/dubbo/${dubbo_pro_list[$4]}/$dd/$aa &> /dev/null && bb=`ls /data/dubbo/${dubbo_pro_list[$4]}/$dd/$aa` && echo -e "There is a \e[1;31mconflict jar.\e[0m" && rm -rf $bb && echo -e "delete the \e[1;31m$bb\e[0m is done."
                 ###
                 cp -R $s /data/dubbo/${dubbo_pro_list[$4]}/$dd/
                 [ "$?" -eq 0 ] && echo -e "copy \e[1;34m$s\e[0m to \e[1;34m/data/dubbo/${dubbo_pro_list[$4]}/$dd/\e[0m is \e[1;32mdone.\e[0m"
                 echo ""
                 break
              else 
                 continue
              fi
           done
        elif [ "$3" == "web" ];then
           for ww in ${web_no_exist_dest_path};do
              read -p "Please input the path that you want to copy(${WEB_START_PATH}$ww/):" wdd
              if [ "$wdd" == "y" ];then
                 local aa=`echo "$s" | grep -o ".*[a-z]-[0-9]\{0,1\}" | sed 's@[0-9]$@*@g'`
                 [ -n "$aa" ] && ls ${WEB_START_PATH}$ww/$aa &> /dev/null && bb=`ls ${WEB_START_PATH}$ww/$aa` && echo -e "There is a \e[1;31mconflict jar.\e[0m" && rm -rf $bb && echo -e "delete the \e[1;31m$bb\e[0m is done." 
                 cp -R $s /data/dubbo${WEB_START_PATH}$ww/
                 [ "$?" -eq 0 ] && echo -e "copy \e[1;34m$s\e[0m to \e[1;34m/data/dubbo${WEB_START_PATH}$ww/\e[0m is \e[1;32mdone.\e[0m"
                 echo ""
                 break
              else 
                 continue
              fi 
           done
        fi
     elif [ "$of" -eq 11 ];then
        echo -e "the \e[1;34m$s\e[0m is \e[1;31mnot only 1.\e[0m"
        for f in ${exist_file_list};do
            exist_file_path=`echo $f | grep -o "/.*/"`
            read -p "Do you want to put $s in this directory?(${exist_file_path}):" C
            if [ "$C" == "y" ];then
               cp -R $s ${exist_file_path}
               [ "$?" -eq 0 ] && echo -e "copy \e[1;34m$s\e[0m to \e[1;34m${exist_file_path}\e[0m is \e[1;32mdone.\e[0m"
               echo ""
               break
            else
               continue
            fi
        done
        #pass#
     fi
  done
}

changeconf() {
 echo -e "##################\e[1;36mmodify configuration file\e[0m#####################################"
 read -p "Do you want to modify configuration file?(y):" cc1
 while true;do
   if [ "$cc1" == "y" ];then
      local n1=0
      if [ "$1" == dubbo ];then
         local dubbo_conf_list=`ls ${dubbo_path_list[$2]}conf/`
         for ii in ${dubbo_conf_list};do
            echo $n1")" $ii 
            dubbo_conf_list_array[$n1]="$ii"
            let n1+=1
         done
         read -p "Please choose the configuration file number:" nn1
         vim ${dubbo_path_list[$2]}conf/${dubbo_conf_list_array[$nn1]}
      elif [ "$1" == "web" ];then
         local web_conf_list=`ls ${WEB_START_PATH}WEB-INF/classes/`
         for ii in ${web_conf_list};do
            echo $n1")" $ii
            web_conf_list_array[$n1]="$ii"
            let n1+=1
         done
         read -p "Please choose the configuration file number:" nn1
         vim ${WEB_START_PATH}WEB-INF/classes/${web_conf_list_array[$nn1]}
      fi
   read -p "Continue to modify the configuration file?(y):" cc1
   else
      break    
   fi
 done  
}

telnetdubbo() {
cat >$1/tel.sh<<EOF
#!/usr/bin/expect
#
set PORT [lindex $argv 0]
spawn telnet 0 $PORT
expect  ""
send "\r"
expect "dubbo>"
send "ls\r"
expect "dubbo>"
send "status\r"
expect "dubbo>"
send "exit\r"
expect eof
exit
EOF
chmod +x $1/tel.sh
$1/tel.sh $2
rm -rf $1/tel.sh
}

restartpro() {
   echo -e "####################\e[1;36mrestart the project\e[0m###########################"
   trap "pkill tail" INT
   read -p "Do you want to restart the project(y/n):" rr
   if [ "$rr" == "y" ];then
      if [ "$1" == "dubbo" ];then
         log=`grep "dubbo.logback.file" ${dubbo_path_list[$2]}conf/dubbo.properties | awk -F= '{print $2}'`
         echo "stopping the ${dubbo_pro_list[$2]}..."
         cd ${dubbo_path_list[$2]}bin/ && bash stop.sh
         sleep 1
         echo "starting the ${dubbo_pro_list[$2]}..."
         bash startup.sh &> /dev/null
         #sleep 1
         tail -f $log
         echo "***********************the process status*******************************************************************"
         ps aux | grep "${dubbo_pro_list[$2]}" | grep -v "grep"
         echo "***********************the listen port**********************************************************************"
         pid=`ps aux | grep "${dubbo_pro_list[$2]}" | grep -v "grep"| awk '{print $2}'`
         [ -n "$pid" ] && netstat -tlnp | grep "$pid"
         echo "*******************************telnet dubbo*******************************************************************"
         read -p "Do you want to telnet dubbo?(y):" xx
         if [ "$xx" == "y" ];then
            PORT=`netstat -tlnp | grep "$pid" | awk -F: '{print $2}' | awk '{print $1}'`
            telnetdubbo /home/tangchengwei $PORT 
         fi
      elif [ "$1" == "web" ];then
         echo "stopping the ${WEB_PROJECT}..."
         /etc/init.d/tomcat stop
         sleep 1
         echo "*********clean up the work dierctory************"
         rm -rf /data/project/${WEB_PROJECT}/work/* && echo "clean up is done."
         echo "**************************************************"
         sleep 1
         echo "starting the ${WEB_PROJECT}..."
         /etc/init.d/tomcat start
         sleep 1
         tail -f /data/logs/catalina.out
         echo "***********************the listen port***********************************************"
         pid=`ps aux | grep "${WEB_PROJECT}" | grep -v "grep" | awk '{print $2}'`
         [ -n "$pid" ] && netstat -tlnp | grep "$pid"
         echo "***********************the process status*************************************************"
         ps aux | grep "${WEB_PROJECT}" | grep -v "grep"
      fi
   fi
}

rollbackpro() {
   read -p "Do you want to rollback? [y|n]" NN
   if [ "$NN" == "y" ];then
      local roll_list_str=`ls /data/backup/`
      local num=0
      for g in $roll_list_str;do
          roll_list[$num]=$g
          echo $num")" ${roll_list[$num]}"==>"`ls /data/backup/${roll_list[$num]}/`
          let num+=1
      done
      read -p "Please input the backup number:" baknum
      local pro=`ls /data/backup/${roll_list[$baknum]} | sed 's@.tar.gz@@' | grep -E -o ^[a-zA-Z]*.[a-zA-Z]\{1,\}`
      if [ "$1" == "dubbo" ];then
        cd /data/dubbo/$pro/bin && bash stop.sh
        rm -rf /data/dubbo/$pro
        cd /data/backup/${roll_list[$baknum]} && tar xf ./* -C /data/dubbo/ 
        [ "$?" -eq 0 ] && echo -e "the $pro rollback is \e[1;32mdone.\e[0m"
      elif [ "$1" == "web" ];then
        /etc/init.d/tomcat stop
        rm -rf /data/webapps/$pro
        cd /data/backup/${roll_list[$baknum]} && tar xf ./* -C /data/webapps/
        [ "$?" -eq 0 ] && echo -e "the $pro rollback is \e[1;32mdone.\e[0m"
      fi
   fi
}


main() {
   getproject &> /dev/null
   num=${#dubbo_path_list[*]}
   #echo ${WEB_PROJECT} ${DUBBO_PATH_LIST}
   if [ -n "${WEB_PROJECT}" -a -n "${DUBBO_PATH_LIST}" ];then
      outproject 1
      echo ""
      read -p "which one is your choice(0,1,2...):" YO
      listfunc $YO yy $1 
   elif [ -z "${WEB_PROJECT}" -a -n "${DUBBO_PATH_LIST}" ];then
      if [ "$num" -eq 1 ];then
         backfunc ${dubbo_pro_list[0]} ${dubbo_path_list[0]} 
         [ "$1" == "deploy" ] && copypackage /home/tangchengwei ${dubbo_path_list[0]} dubbo 0
         [ "$1" == "rollback" ] && rollbackpro dubbo && restartpro dubbo 0 && exit
         changeconf dubbo 0
         restartpro dubbo 0
      else
         outproject 0
         read -p "which one is your choice(1,2...):" YO
         listfunc $YO ny
      fi
   elif [ -z "${DUBBO_PATH_LIST}" -a -n "${WEB_PROJECT}" ];then   
      #backfunc ${dubbo_pro_list[$1-1]} ${dubbo_path_list[$1-1]}
       backfunc ${WEB_PROJECT} ${WEB_START_PATH}
       [ "$1" == "deploy" ] && copypackage /home/tangchengwei ${WEB_START_PATH} web
       [ "$1" == "rollback" ] && rollbackpro web && chown -R tomcat.tomcat ${WEB_START_PATH} && restartpro web && exit
       chown -R tomcat.tomcat ${WEB_START_PATH}
       changeconf web 
       restartpro web
   else 
      echo -e "there is \e[1;31mno project\e[0m need to be operated."
   fi
}

case $1 in 
deploy)
  main deploy
  ;;
rollback)
  main rollback
  ;;
*)
  echo "Usage: rollback [deploy|rollback]"
  exit 1
esac

rm -rf /home/tangchengwei/file/* &> /dev/null








