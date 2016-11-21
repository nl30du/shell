#!/bin/bash

host_ip=`ifconfig  | grep 'inet addr:'| grep -v '127.0.0.1' |cut -d: -f2 | awk '{ print $1}'`
#host_ip=`ifconfig |awk '/192/ {print $2}'|awk  -F":" '{print $2}'`
service_ip='10.0.18.6'

cat > /etc/zabbix/zabbix_agentd.conf << EOF
PidFile=/tmp/zabbix_agentd.pid
LogFile=/tmp/zabbix_agentd.log
LogFileSize=10
DebugLevel=2
StartAgents=10
RefreshActiveChecks=300
BufferSize=200
Server=${service_ip}
ListenPort=10050
ListenIP=${host_ip}
StartAgents=5
ServerActive=${service_ip}:10051
UnsafeUserParameters=1
Include=/etc/zabbix/zabbix_agentd.conf.d/

EOF

cat > /etc/zabbix/zabbix_agent.conf << EOF
PidFile=/tmp/zabbix_agentd.pid
LogFile=/tmp/zabbix_agentd.log
LogFileSize=10
DebugLevel=2
StartAgents=10
RefreshActiveChecks=300
BufferSize=200
Server=${service_ip}
ListenPort=10050
ListenIP=${host_ip}
StartAgents=5
ServerActive=${service_ip}:10051
UnsafeUserParameters=1
Include=/etc/zabbix/zabbix_agentd.conf.d/

EOF

cat > /etc/zabbix/zabbix_agentd.conf.d/socket.conf << EOF
UserParameter=sockstat.sockets,cat /proc/net/sockstat|grep sockets|cut -d' ' -f 3
UserParameter=sockstat.tcp.inuse,cat /proc/net/sockstat|grep TCP|cut -d' ' -f 3
UserParameter=sockstat.tcp.orphan,cat /proc/net/sockstat|grep TCP|cut -d' ' -f 5
UserParameter=sockstat.tcp.timewait,cat /proc/net/sockstat|grep TCP|cut -d' ' -f 7
UserParameter=sockstat.tcp.allo,cated,cat /proc/net/sockstat|grep TCP|cut -d' ' -f 9
UserParameter=sockstat.tcp.mem,cat /proc/net/sockstat|grep TCP|cut -d' ' -f 11
UserParameter=sockstat.udp.inuse,cat /proc/net/sockstat|grep UDP:|cut -d' ' -f 3
UserParameter=sockstat.udp.mem,cat /proc/net/sockstat|grep UDP:|cut -d' ' -f 5

EOF


/etc/init.d/zabbix-agent restart
#/etc/init.d/zabbix-agentd restart
/etc/init.d/iptables stop
