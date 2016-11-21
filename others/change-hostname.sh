#!/bin/bash
#ip=$(ifconfig|awk '/10.0/ {print $2}'|awk -F":" '{print $2}' |awk -F "."  '{print $1"-"$2"-"$3"-"$4}')
ip=$(ifconfig|awk '/10.0/ {print $2}'|awk -F":" '{print $2}' | head -1 | awk -F "."  '{print $1"-"$2"-"$3"-"$4}')
asd=`ifconfig | grep "Bcast" |  awk -F: '{print $2}' | awk '{print $1}'`
#echo $ip1
TAG="BJ-LOCAL-NEWTEST"

#CUR_HOST_NAME=`hostname`
HOST_NAME=${TAG}-${ip}
#echo $HOST_NAME
#sed -i s/$CUR_HOST_NAME/$HOST_NAME/g /etc/hosts
#sed -i s/$CUR_HOST_NAME/$HOST_NAME/g /etc/sysconfig/network
echo $asd  $HOST_NAME >> /etc/hosts
sed -i 's@HOSTNAME=.*@@g' /etc/sysconfig/network
echo "HOSTNAME="${HOST_NAME} >> /etc/sysconfig/network
sed -i /^$/d /etc/sysconfig/network
hostname $HOST_NAME
