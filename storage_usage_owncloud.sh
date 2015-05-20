#!/bin/bash
LOG_OC=/tmp/storage_oc_`date +%Y_%m_%d`.log
LOG_KL=/tmp/storage_kl_`date +%Y_%m_%d`.log
LOG_STORAGE=/tmp/storage_total.log

# archive old LogFile
mv $LOG_STORAGE /tmp/storage_total_OLD.log

################################################################################### OWNCLOUD STORAGE USAGE

echo "#################### OWNCLOUD ####################" > $LOG_OC

user="root"
password="yourpassword"
dbname="yourownclouddb"

for Dir in /var/www/owncloud/data/* `find . -type d`
 do
        CMD=$(du -hsm $Dir | grep -o '^\S*')
        FNAME=$(echo $Dir | awk '{gsub("/var/www/owncloud/data/", "");print}')
        USERS=$(echo "select ldap_dn from oc_ldap_user_mapping where owncloud_name='$FNAME';" | mysql -u $user -p$password $dbname | grep -v "ldap_dn" | sed -r 's/^.{4}//' | cut -f1 -d",")
        echo $USERS $CMD | awk '{gsub("/var/www/owncloud/data/", "");print}'  >> $LOG_OC
done


## Company1
getCOM1=$(grep -F "@company1.ch" $LOG_OC | cut -d " " -f2)
COM1size=$(echo $getCOM1 | tr ' ' '+')
echo "#### Company1 SIZE="$COM1size >> $LOG_OC
echo "#### Company1 TOTAL="$(($COM1size)) >> $LOG_OC
echo "Company1;Storage OwnCloud;storage;"$(($COM1size)) >> $LOG_STORAGE


## Company2
getCOM2=$(grep -F "@company2.ch" $LOG_OC | cut -d " " -f2)
COM2size=$(echo $getCOM2 | tr ' ' '+')
echo "#### Company2 SIZE="$COM2size >> $LOG_OC
echo "#### Company2 TOTAL="$(($COM2size)) >> $LOG_OC
echo "Company2;Storage OwnCloud;storage;"$(($COM2size)) >> $LOG_STORAGE

################################################################################ KOLAB STORAGE USAGE

# get Kolab Log
scp root@ipfromkolabhost:$LOG_KL $LOG_KL

sleep 2
## Company1
getCOM1_KL=$(grep -F "company1.ch" $LOG_KL)
echo "Company1;Storage Kolab;storage;"${getCOM1_KL%%/var*} >> $LOG_STORAGE

## Company2
getCOM2_KL=$(grep -F "company2.ch" $LOG_KL)
echo "Company2;Storage Kolab;storage;"${getCOM2_KL%%/var*} >> $LOG_STORAGE