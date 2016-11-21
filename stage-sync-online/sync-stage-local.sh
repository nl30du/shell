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
   echo ${dest_dir_real}
   online_real=`grep "${dest_dir_real}" /home/tangchengwei/package/cmd/online-temple.txt | awk -F: '{print $2}'` 
   echo "${online_real}:/home/tangchengwei/sync"
   rsync -avzr -e "ssh -p 50022" --delete /home/tangchengwei/package/stage/${dest_dir_real} ${online_real}:/home/tangchengwei/sync/
    
done


