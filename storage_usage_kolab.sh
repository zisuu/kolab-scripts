#!/bin/bash
LOG=/tmp/storage_kl_`date +%Y_%m_%d`.log

echo "################## KOLAB ######################" >> $LOG

for Dir in /var/spool/imap/domain/* `find . -type d`
do
        du -hm --max-depth=1 ${Dir} | grep /var/spool/imap/domain/ >> $LOG
done
