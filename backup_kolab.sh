#!/bin/bash

echo "#####################################################################"
date

echo "--- START LDAP BACKUP ---"
# create Folders
LDAPFOLDER="/backup/ldapBackup"
LDIFFOLDER="/backup/ldapBackup/ldif"
ARCFOLDER="/backup/ldapBackup/archive"

if [ ! -d ${LDAPFOLDER} ] ; then
        mkdir ${LDAPFOLDER}
        echo "Folder ${LDAPFOLDER} has been created"
else
        echo "Folder ${LDAPFOLDER} already exists"
fi
if [ ! -d ${LDIFFOLDER} ] ; then
        mkdir ${LDIFFOLDER}
        echo "Folder ${LDIFFOLDER} has been created"
else
        echo "Folder ${LDIFFOLDER} already exists"
fi
if [ ! -d ${ARCFOLDER} ] ; then
        mkdir ${ARCFOLDER}
        echo "Folder ${ARCFOLDER} has been created"
else
        echo "Folder ${ARCFOLDER} already exists"
fi

# cleanup last ldap backup
find ${LDIFFOLDER} -maxdepth 1 -type f -name "*.ldif" -delete


# create new backup of ldap domains
for dir in `find /etc/dirsrv/ -mindepth 1 -maxdepth 1 -type d \
        -name "slapd-*" | xargs -n 1 basename`; do

    for nsdb in `find /var/lib/dirsrv/${dir}/db/ -mindepth 1 \
            -maxdepth 1 -type d | xargs -n 1 basename`; do

        /usr/sbin/ns-slapd db2ldif -D /etc/dirsrv/${dir} -n ${nsdb} -a - \
             >  ${LDIFFOLDER}/$(hostname)-$(echo ${dir} | sed -e 's/slapd-//g')-${nsdb}.ldif
    done
done

# archive
tar -czf ${ARCFOLDER}/dirsrv-$(date +'%Y%m%d-%H%M%S').tar.gz -C / /etc/dirsrv/ ${LDIFFOLDER}
find ${ARCFOLDER} -name 'dirsrv-*' -mtime +31 -type f -delete

echo "--- LDAP BACKUP DONE! ---"

echo "--- START MYSQL BACKUP ---"
# create Folders
MYSQLFOLDER="/backup/mysqlBackup/"

if [ ! -d ${MYSQLFOLDER} ] ; then
        mkdir ${MYSQLFOLDER}
        echo "Folder ${MYSQLFOLDER} has been created"
else
        echo "Folder ${MYSQLFOLDER} already exists"
fi

# define mysql access

USER="root"
PASS="setpasswordhere"
DIR="${MYSQLFOLDER}/db"

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

echo "--- START CYRUS BACKUP ---"

# Location of the backup directory
CYRUSFOLDERDIR=/backup/cyrus/

# Name of the backup archive
BACKUPFILE=cyrus_backup_`date +%Y_%m_%d_%H_%M`.tar.bz2

# Path of the Cyrus spool and account directory
SPOOLDIR=/var/spool/imap
ACCOUNTINGDIR=/var/lib/imap

# Log file
LOGFILE=/var/log/cyrus_backup.log

# Lock file
LOCK=/var/tmp/cyrus_backup.lock

find ${CYRUSFOLDERDIR} -name 'cyrus_backup_*' -mtime +31 -delete


log()
  {
    echo `date +%d.%m.%Y%t%H:%M:%S` "    LOG:" $1 | tee -a ${LOGFILE}
  }

error()
  {
    echo `date +%d.%m.%Y%t%H:%M:%S` "    ERROR:" $1 | tee -a ${LOGFILE}
    exit 1
  }

if [ -f ${LOCK} ] ; then
  error "Lockfile ${LOCK} exists."
fi

touch ${LOCK}

if [ ! -d ${CYRUSFOLDERDIR} ] ; then
        mkdir ${CYRUSFOLDERDIR}
        echo "Folder ${CYRUSFOLDERDIR} has been created"
else
        echo "Folder ${CYRUSFOLDERDIR} already exists"
fi

log "Suspending mail system"
echo "Cyrus IMAP suspended ..." > /var/lib/imap/msg/shutdown

log "Starting backup process"
umask 066
if [ -z "$(cat /etc/passwd | grep ^cyrus | grep /sbin/nologin$)" ] ; then
  su - cyrus -c "/usr/lib/cyrus-imapd/ctl_mboxlist -d" > /var/tmp/mailboxlist.txt
else
  usermod -s /bin/bash cyrus
  su - cyrus -c "/usr/lib/cyrus-imapd/ctl_mboxlist -d" > /var/tmp/mailboxlist.txt
  usermod -s /sbin/nologin cyrus
fi
tar cjpf ${CYRUSFOLDERDIR}${BACKUPFILE} ${SPOOLDIR} ${ACCOUNTINGDIR} /var/tmp/mailboxlist.txt
rm -f /var/tmp/mailboxlist.txt

log "Resuming mail system"

rm -f /var/lib/imap/msg/shutdown
echo "Cyrus IMAP resuming ..."
postqueue -f

rm -f ${LOCK}

echo "--- CYRUS BACKUP DONE! ---"

echo "--- STARTING POSTFIX BACKUP ---"

POSTFIXDIR=/backup/postfix/

if [ ! -d ${POSTFIXDIR} ] ; then
        mkdir ${POSTFIXDIR}
        echo "Folder ${POSTFIXDIR} has been created"
else
        echo "Folder ${POSTFIXDIR} already exists"
fi

POSTFIX_RUNNING=postfix_running_backup_`date +%Y_%m_%d_%H_%M`.tar.bz2

POSTFIX_STOP=postfix_stop_backup_`date +%Y_%m_%d_%H_%M`.tar.bz2

find ${POSTFIXDIR} -name 'postfix_*' -mtime +31 -delete

tar cjpf ${POSTFIXDIR}${POSTFIX_RUNNING} /var/spool/postfix

/etc/init.d/postfix stop

tar cjpf ${POSTFIXDIR}${POSTFIX_STOP} /var/spool/postfix

/etc/init.d/postfix start


echo "--- POSTFIX BACKUP DONE! ---"


echo "--- STARTING KOLAB CONFIG BACKUP ---"

KOLABCONFDIR=/backup/kolabconf/

if [ ! -d ${KOLABCONFDIR} ] ; then
        mkdir ${KOLABCONFDIR}
        echo "Folder ${KOLABCONFDIR} has been created"
else
        echo "Folder ${KOLABCONFDIR} already exists"
fi

KOLABCONF1=kolab_config_`date +%Y_%m_%d_%H_%M`.tar.bz2
KOLABCONF2=kolab-freebusy_config_`date +%Y_%m_%d_%H_%M`.tar.bz2
KOLABCONF3=kolab-syncroton_config_`date +%Y_%m_%d_%H_%M`.tar.bz2
KOLABCONF4=kolab-webadmin_config_`date +%Y_%m_%d_%H_%M`.tar.bz2
KOLABCONF5=roundcubemail_config_`date +%Y_%m_%d_%H_%M`.tar.bz2
KOLABCONF6=iRony_config_`date +%Y_%m_%d_%H_%M`.tar.bz2

find ${KOLABCONFDIR} -name 'kolab_*' -mtime +31 -delete

tar cjpf ${KOLABCONFDIR}${KOLABCONF1} /usr/share/kolab/
tar cjpf ${KOLABCONFDIR}${KOLABCONF2} /usr/share/kolab-freebusy/
tar cjpf ${KOLABCONFDIR}${KOLABCONF3} /usr/share/kolab-syncroton/
tar cjpf ${KOLABCONFDIR}${KOLABCONF4} /usr/share/kolab-webadmin/
tar cjpf ${KOLABCONFDIR}${KOLABCONF5} /usr/share/roundcubemail
tar cjpf ${KOLABCONFDIR}${KOLABCONF6} /usr/share/iRony/

echo "--- KOLAB CONFIG BACKUP DONE! ---"
echo "--- STARTING SUPPORT WEB BACKUP ---"

SUPPORTDIR=/backup/support/

if [ ! -d ${SUPPORTDIR} ] ; then
        mkdir ${SUPPORTDIR}
        echo "Folder ${SUPPORTDIR} has been created"
else
        echo "Folder ${SUPPORTDIR} already exists"
fi

SUPPORTBKP=support_`date +%Y_%m_%d_%H_%M`.tar.bz2


find ${SUPPORTDIR} -name 'support_*' -mtime +31 -delete

tar cjpf ${SUPPORTDIR}${SUPPORTBKP} /var/www/support/

echo "--- SUPPORT WEB BACKUP DONE! ---"
