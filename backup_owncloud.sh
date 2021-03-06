#!/bin/bash

echo "#####################################################################"
date

echo "--- START MYSQL BACKUP ---"
# create Folder
MYSQLFOLDER="/yourmysqlbackupdir/"

if [ ! -d ${MYSQLFOLDER} ] ; then
        mkdir ${MYSQLFOLDER}
        echo "Folder ${MYSQLFOLDER} has been created"
else
        echo "Folder ${MYSQLFOLDER} already exists"
fi


# define mysql access

USER="root"
PASS="yourPassword"
DIR="/yourbackupDIR"

# Connect to mysql

ALL=$(mysql -u $USER --password=$PASS -N -B -e "SHOW DATABASES" | egrep -v "(information_schema|performance_schema)")
if [ "$?" != "0" ] ; then
        echo "ERROR: can't connect to mysql"
        exit 1
fi

for DB in $ALL ; do
        echo "### $DB"
        echo "# `date`"
        if [ ! -d $DIR/$DB ] ; then
                mkdir -p $DIR/$DB
        fi
        cd $DIR/$DB
        # move old backups to *.old
        for F in `ls *.sql.gz 2> /dev/null` ; do mv $F $F.old ; done

        # walkthrough every table
        for TABLE in $(mysql -u $USER --password="$PASS" -N -D "$DB" -B -e "SHOW TABLES") "__internal" ; do
                echo -n "-- $TABLE"

                # dump
                if [ "$TABLE" == "__internal" ] ; then
                        # internal stuff (views, procedures, triggers)
                        # mysqldump --no-create-info --no-data --routines --triggers --events
                        mysqldump -u "$USER" --password="$PASS" --skip-dump-date \
                            --single-transaction --quick --lock-tables=false \
                            --default-character-set=utf8 -Q -q "$DB" \
                            --no-data --no-create-info --routines --triggers \
                            | gzip > $TABLE.tmp.gz
                else
                        # normal
                         mysqldump -u "$USER" --password="$PASS" --add-drop-table --skip-dump-date \
                            --single-transaction --quick --lock-tables=false \
                            --default-character-set=utf8 -Q -q --hex-blob "$DB" "$TABLE" \
                            | gzip > $TABLE.tmp.gz

                fi

                # check for modifications
                zcmp $TABLE.sql.gz.old $TABLE.tmp.gz > /dev/null 2>&1
                if [ "$?" != "0" ]; then
                        echo " - CHANGED"
                        mv $TABLE.tmp.gz $TABLE.sql.gz
                        if [ -f $TABLE.sql.gz.old ] ; then rm $TABLE.sql.gz.old ; fi
                else
                        echo ""
                        mv $TABLE.sql.gz.old $TABLE.sql.gz
                        rm $TABLE.tmp.gz
                fi
        done

        # deleting old dumps
        for F in `ls *.old 2>/dev/null ` ; do
                echo "-- # delete # $F"
                rm $F
        done
done
echo "--- MYSQL BACKUP DONE! ---"

echo "--- BACKUP OWNCLOUD USER DATA ---"
# create Folder
OCFOLDER="/yourowncloudbackupfolder/"

if [ ! -d ${OCFOLDER} ] ; then
        mkdir ${OCFOLDER}
        echo "Folder ${OCFOLDER} has been created"
else
        echo "Folder ${OCFOLDER} already exists"
fi

rdiff-backup /var/www/owncloud/data ${OCFOLDER}

# delete data backup files older than 4 weeks
rdiff-backup  --force --remove-older-than 10W ${OCFOLDER}

echo "--- OWNCLOUD USER DATA BACKUP DONE! ---"


echo "--- BACKUP OWNCLOUD CONFIG ---"
BACKUPFILE=owncloud_backup_config_`date +%Y_%m_%d_%H_%M`.tar.bz2

tar cjpf ${OCFOLDER}${BACKUPFILE} /var/www/owncloud/config

echo "--- OWNCLOUD CONFIG BACKUP DONE!"

