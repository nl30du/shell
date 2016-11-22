#!/bin/bash
#
file_name="appapi_access dock_access fhgc_access hqg_access master_mirror_access mfds_access nginx_error old-report_access pay_access pic_access product_access report_access reportcn_access settl_access sku_access supply_access support_access timer_access travel_access voucher_access yabyy_access"

#nginx's log direcory
LOGS_PATH=/data/nginx/logs
#one day's log
YESTERDAY=$(date -d "yesterday" +%Y-%m-%d)
#cut the log
for i in ${file_name};do
  mv ${LOGS_PATH}/$i.log ${LOGS_PATH}/days-logs/$i-${YESTERDAY}.log
#sent USR1 to nginx,reload the nginx of configuration file
  kill -USR1 `ps aux | grep "nginx: master process" | grep -v grep | awk '{print $2}'`
  cd ${LOGS_PATH}/days-logs/
#delete 7 days's log file
  find ./ -mtime +8 -name "*20[0-9][0-9]*" | xargs rm -f &> /dev/null
done
exit 0
