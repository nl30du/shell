#!/bin/bash                                        
#


inotifywait -rqm -e modify,attrib,moved_to,moved_from,move,move_self,create,delete,delete_self --timefmt='%d/%m/%y %H:%M' --format='%T %w%f %e' /home/tomcat/logs  | while read chgeFile;do 
    #rsync -avqz -e "ssh -p 50022" /home/backup/*.tar.gz dbback@$1:/data/dbback/10.10.14.10/;
    sleep 25
    pkill tail 
done

