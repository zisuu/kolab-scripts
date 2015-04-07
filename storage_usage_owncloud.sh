#!/bin/bash
LOG_OC=/tmp/storage_oc_`date +%Y_%m_%d`.log
LOG_KL=/tmp/storage_kl_`date +%Y_%m_%d`.log
LOG_DEST=/var/www/owncloud/data/youruseruuid/files/

echo "#################### OWNCLOUD ####################" >> $LOG_OC

user="root"
password="yourpassword"
dbname="owncloud_db"

for Dir in /var/www/owncloud/data/* `find . -type d`
 do
        du -hs $Dir | awk '{gsub("/var/www/owncloud/data/", "");print}' >> $LOG_OC
        FNAME=$(echo $Dir | awk '{gsub("/var/www/owncloud/data/", "");print}')
        QUERY=$(echo "select ldap_dn from oc_ldap_user_mapping where owncloud_name='$FNAME';" | mysql -u $user -p$password $dbname | grep -v "ldap_dn")
        RESULT=${QUERY}
        echo $RESULT | sed -r 's/^.{4}//' | cut -f1 -d"," >> $LOG_OC
done

scp root@192.168.31.75:$LOG_KL $LOG_DEST
cp $LOG_OC $LOG_DEST