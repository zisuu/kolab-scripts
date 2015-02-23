#!/bin/bash

echo "#####################################################################"
date

echo "--- START LDAP BACKUP ---"
# create Folders
mkdir /backup/ldapBackup
mkdir /backup/ldapBackup/ldif
mkdir /backup/ldapBackup/archive/

# cleanup last ldap backup
find /backup/ldapBackup/ldif/ -maxdepth 1 -type f -name "*.ldif" -delete


# create new backup of ldap domains
for dir in `find /etc/dirsrv/ -mindepth 1 -maxdepth 1 -type d \
        -name "slapd-*" | xargs -n 1 basename`; do

    for nsdb in `find /var/lib/dirsrv/${dir}/db/ -mindepth 1 \
            -maxdepth 1 -type d | xargs -n 1 basename`; do

        /usr/sbin/ns-slapd db2ldif -D /etc/dirsrv/${dir} -n ${nsdb} -a - \
             >  /backup/ldapBackup/ldif/$(hostname)-$(echo ${dir} | sed -e 's/slapd-//g')-${nsdb}.ldif
    done
done

# archive
tar -czf /backup/ldapBackup/archive/dirsrv-$(date +'%Y%m%d-%H%M%S').tar.gz -C / etc/dirsrv/ backup/ldapBackup/ldif/
find /backup/ldapBackup/archive/ -name 'dirsrv-*' -mtime +31 -type f -delete

echo "--- LDAP BACKUP DONE! ---"

echo "--- START MYSQL BACKUP ---"
# create Folders
mkdir /backup/mysql/{db,log}

# define mysql access

USER="root"
PASS="set password here"
DIR="/backup/mysqlBackup/db"

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
BACKUPDIR=/backup/cyrus/

# Name of the backup archive
BACKUPFILE=cyrus_backup_`date +%Y_%m_%d_%H_%M`.tar.bz2

# Path of the Cyrus spool and account directory
SPOOLDIR=/var/spool/imap
ACCOUNTINGDIR=/var/lib/imap/user

# Log file
LOGFILE=/var/log/cyrus_backup.log

# Lock file
LOCK=/var/tmp/cyrus_backup.lock

find /backup/cyrus/ -name 'cyrus_backup_*' -mtime +31 -delete


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

if [ ! -d ${BACKUPDIR} ] ; then
  log "Creating backup directory"
  mkdir -p ${BACKUPDIR}
fi

log "Suspending mail system"
echo "Server Suspended ..." > /var/lib/imap/msg/shutdown

log "Starting backup process"
umask 066
if [ -z "$(cat /etc/passwd | grep ^cyrus | grep /sbin/nologin$)" ] ; then
  su - cyrus -c "/usr/lib/cyrus-imapd/ctl_mboxlist -d" > /var/tmp/mailboxlist.txt
else
  usermod -s /bin/bash cyrus
  su - cyrus -c "/usr/lib/cyrus-imapd/ctl_mboxlist -d" > /var/tmp/mailboxlist.txt
  usermod -s /sbin/nologin cyrus
fi
tar cjpf ${BACKUPDIR}${BACKUPFILE} ${SPOOLDIR} ${ACCOUNTINGDIR} /var/tmp/mailboxlist.txt
rm -f /var/tmp/mailboxlist.txt

log "Resuming mail system"
rm -f /var/lib/imap/msg/shutdown
postqueue -f

rm -f ${LOCK}

echo "--- CYRUS BACKUP DONE! ---"

echo "--- STARTING POSTFIX BACKUP ---"

BACKUPDIR2=/backup/postfix/
mkdir ${BACKUPDIR2}

BACKUPFILE2_RUNNING=postfix_running_backup_`date +%Y_%m_%d_%H_%M`.tar.bz2

BACKUPFILE2_STOP=postfix_stop_backup_`date +%Y_%m_%d_%H_%M`.tar.bz2

find /backup/postfix/ -name 'postfix_*' -mtime +31 -delete

tar cjpf ${BACKUPDIR2}${BACKUPFILE2_RUNNING} /var/spool/postfix

/etc/init.d/postfix stop

tar cjpf ${BACKUPDIR2}${BACKUPFILE2_STOP} /var/spool/postfix

/etc/init.d/postfix start


echo "--- POSTFIX BACKUP DONE! ---"
