#!/bin/bash
#
#

for i in $@;do
   dow=`grep "$i" /home/tangchengwei/package/cmd/stage-temple.txt | awk -F: '{print $3}'`
   if [[ -z $dow ]];then
     echo "the $i is not matched in stage-temple."
     continue
   fi
   dest_dir_real=`grep "$i" /home/tangchengwei/package/cmd/stage-temple.txt | awk -F: '{print $4}'`
   dest_dir_real_ip=`grep "$i" /home/tangchengwei/package/cmd/stage-temple.txt | awk -F: '{print $2}'`
   #echo "${dest_dir_real_ip}"
   number=`echo "${dest_dir_real}" | wc -l`
   if [[ $number -ne 1 ]];then
      echo -e "\e[1;34m${dest_dir_real}\e[0m"
      exit 1
   fi
   dest_dir=/data/$dow/${dest_dir_real}/
   #echo "${dest_dir}"
   [[ -d /home/tangchengwei/package/stage/${dest_dir_real} ]] || mkdir /home/tangchengwei/package/stage/${dest_dir_real} 
   rsync -avzr -e "ssh -p 50022" --delete ${dest_dir_real_ip}:${dest_dir} /home/tangchengwei/package/stage/${dest_dir_real}/
   sleep 1 
   #echo ${dest_dir_real}
   online_real=`grep "${dest_dir_real}" /home/tangchengwei/package/cmd/online-temple.txt | awk -F: '{print $2}'` 
   echo "--------------------------------------------------------------------------------"
   #echo "${online_real}:/home/tomcat|dubbo/sync"
   #echo $dow
   if [ "$dow" == "dubbo" ];then
	rsync -avzr -e "ssh -p 50022 -i /home/tangchengwei/key/id_rsa" --delete /home/tangchengwei/package/stage/${dest_dir_real} dubbo@${online_real}:/home/dubbo/sync/ && \
	ssh -p 50022 -i /home/tangchengwei/key/id_rsa dubbo@${online_real} "bash /home/dubbo/deploy-d.sh"
	echo "${online_real}:/home/dubbo/sync"
	#get other one from online-other
	echo "---------------------------------------------------------------------------"
	other_ip=`cat /home/tangchengwei/package/cmd/online-other.txt | grep "$1" | awk -F: '{print $2}'`
	read -p "Do you want to stop [ $1:${other_ip} ] ? [y|n]" AN
        if [ "$AN" == "y" ];then
            ssh -p 50022 -i /home/tangchengwei/key/id_rsa dubbo@${other_ip} "/etc/init.d/dubbo stop"
        fi

   elif [ "$dow" == "webapps" ];then
        rsync -avzr -e "ssh -p 50022 -i /home/tangchengwei/key/id_rsa" --delete /home/tangchengwei/package/stage/${dest_dir_real} tomcat@${online_real}:/home/tomcat/sync/ && \
	ssh -p 50022 -i /home/tangchengwei/key/id_rsa tomcat@${online_real} "bash /home/tomcat/deploy-w.sh"
	echo "${online_real}:/home/tomcat/sync"
	#get other one from online-other
	echo "---------------------------------------------------------------------------"
	other_ip=`cat /home/tangchengwei/package/cmd/online-other.txt | grep "$1" | awk -F: '{print $2}'`
	read -p "Do you want to stop [ $1:${other_ip} ] ? [y|n]" AN
	if [ "$AN" == "y" ];then
	    ssh -p 50022 -i /home/tangchengwei/key/id_rsa tomcat@${other_ip} "/etc/init.d/tomcat stop"
	fi
	    
   fi
   #echo "-----------------------------------------------"
   #echo "${online_real}"
done


