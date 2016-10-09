#!/bin/bash                                        
#

rsync -avqz -e "ssh -p 50022" /root/aa/ root@$1:/data/test/

inotifywait -mrq -e modify,attrib,moved_to,moved_from,move,move_self,create,delete,delete_self --timefmt='%d/%m/%y %H:%M' --format='%T %w%f %e' /root/aa  | while read chgeFile;do rsync -avqz -e "ssh -p 50022" /root/aa/ root@$1:/data/test/;done
