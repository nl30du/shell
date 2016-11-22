#!/bin/bash


n=`ls -l /data/backup | grep 2016.*[0-9]$ | wc -l`
if [ "$n" -gt 7 ];then
   echo `hostname`
   num=`ls -l /data/backup/ | grep 2016.*[0-9]$ | wc -l`
   let num1=$num-7
   #ls -l /data/backup/ | grep 2016.*[0-9]$ | head -$num1
   cd /data/backup && rm -rf `ls /data/backup/ | grep 2016.*[0-9]$ | head -$num1`
fi
