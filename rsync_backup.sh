#! /bin/sh
ROOT_UID=0

if [ $UID != $ROOT_UID ]; then
        echo "You are not root."
        exit 1
fi

export PATH="${PATH:+$PATH:}/usr/sbin:/sbin"
RUNNER='nice /usr/bin/rsync'
COMPRESS_ARGS=' -v --archive --compress --del --delete-excluded --force --ignore-errors --inplace --recursive --update'
NO_INPLACE_COMPRESS_ARGS='-v --archive --compress --del --delete-excluded --force --ignore-errors --recursive --update'
NON_COMPRESS_ARGS='-v --archive --del --delete-excluded --force --ignore-errors --inplace --recursive --update'
TEMP_DIR='--temp-dir=/tmp'
SSH_COMMAND='ssh -p 8080 -i'
SEVEN_DAYS_AGO_DATE=`date --date=" - 7 days" +%F`
TODAYS_DATE=`date +%F`

# To force a date - Remove comment and put in date
#TODAYS_DATE=2009-05-15

CURRENT_EPOCH_DATE=`date +%s`
BACKUP_DRIVE_MOUNT='/mnt/backup_drive'
DESTINATION="$BACKUP_DRIVE_MOUNT/${TODAYS_DATE}"
PUBLIC_KEY_PATH='/root/backup_ssh_keys'
LOG_FILE='/tmp/backup.log';
MAIL_SUBJECT='Backup';
RECEIPIENT='stats@host.com';
MAIL_SIZE='1000000';

if [ -f /tmp/back_busy ];
then
        echo "Backup in progress"
        exit 1;
fi

if [ -f ${LOG_FILE} ];
then
        rm -f ${LOG_FILE}
fi

mount /dev/sda1 $BACKUP_DRIVE_MOUNT
CALCULATED_EPOCH=$(( ${CURRENT_EPOCH_DATE} - `cat ${BACKUP_DRIVE_MOUNT}/week_of_year`))

if [  ! -f ${BACKUP_DRIVE_MOUNT}/write_to_me ];
then
        echo "write_to_me file does not exist, therefore cant read or write to disk."
        exit 1;
fi

if [ "$CALCULATED_EPOCH" -gt "1209581" ]
then
        echo "Drive backup greater than two weeks therefore renaming all directories to integers."

        COUNT=1
        for i in `find ${BACKUP_DRIVE_MOUNT}/* -maxdepth 0 -type d`; do
            if [ ! -d ${BACKUP_DRIVE_MOUNT}/$COUNT ];
            then
                echo "Moving ${BACKUP_DRIVE_MOUNT}/$COUNT"
                mv $i ${BACKUP_DRIVE_MOUNT}/$COUNT;
            else
                echo "Cant rename ${BACKUP_DRIVE_MOUNT}/$COUNT as it already exists"
            fi

            COUNT=$(( $COUNT + 1 ))
        done
fi


if [ -d ${BACKUP_DRIVE_MOUNT}/${SEVEN_DAYS_AGO_DATE} ];
then
        # move last weeks directory (date) to todays directory (date)
        mv  ${BACKUP_DRIVE_MOUNT}/${SEVEN_DAYS_AGO_DATE} ${DESTINATION}

elif [ -d ${BACKUP_DRIVE_MOUNT}/1 ] && [ ! -d ${DESTINATION} ]
then
        mv  ${BACKUP_DRIVE_MOUNT}/1 ${DESTINATION}

        for i in `seq 2 5`; do
            if [ -d ${BACKUP_DRIVE_MOUNT}/$i ];
            then
                mv ${BACKUP_DRIVE_MOUNT}/$i ${BACKUP_DRIVE_MOUNT}/$(( $i - 1 ))
            fi
        done
fi

touch /tmp/back_busy

# sixaside@fred.host.com
echo "Backing up sixaside@fred.host.com"
$RUNNER $COMPRESS_ARGS $TEMP_DIR \
        --rsh="$SSH_COMMAND $PUBLIC_KEY_PATH/sixaside@fred.host.com.id_rsa" \
        fiveaside@fred.host.com:~/ \
        $DESTINATION/sixaside\@fred.host.com \
        1>> ${LOG_FILE}

# faxserver
echo "Backing up faxserver"
$RUNNER $NON_COMPRESS_ARGS $TEMP_DIR \
        --password-file=/root/passwordfile \
        192.168.111.237::faxserver \
        $DESTINATION/faxserver/active_fax/ \
        1>> ${LOG_FILE}

# dms - bookings
echo "Backing up dms - bookings"
$RUNNER $NON_COMPRESS_ARGS $TEMP_DIR \
        --password-file=/root/passwordfile \
        dms.host.local::bookings_backup \
        $DESTINATION/dms.host.local/bookings/ \
        1>> ${LOG_FILE}

# dms - web
echo "Backing up dms - web"
$RUNNER $NON_COMPRESS_ARGS $TEMP_DIR \
        --password-file=/root/passwordfile \
        dms.host.local::web_backup \
        $DESTINATION/dms.host.local/programs/ \
        1>> ${LOG_FILE}


# liveassistance@fred.host.com
echo "Backing up liveassistance@fred.host.com"
$RUNNER $COMPRESS_ARGS $TEMP_DIR \
        --rsh="$SSH_COMMAND $PUBLIC_KEY_PATH/liveassistance@fred.host.com.id_rsa" \
        liveassistance@fred.host.com:~/ \
        $DESTINATION/liveassistance\@fred.host.com \
        1>> ${LOG_FILE}

# mitm.host.local
echo "Backing up mitm.host.local"
$RUNNER $COMPRESS_ARGS $TEMP_DIR \
        --rsh="ssh -i $PUBLIC_KEY_PATH/mitm.host.local.id_rsa" \
        root@mitm.host.local:/usr/local/www/apache22/cgi-bin \
        $DESTINATION/mitm.host.local \
        1>> ${LOG_FILE}

# CTSQL
echo "Backing up CTSQL"
$RUNNER $NON_COMPRESS_ARGS $TEMP_DIR \
        /mnt/ctsql \
        $DESTINATION/ \
        1>> ${LOG_FILE}

# Users mail
echo "Backing up mail"
$RUNNER $NON_COMPRESS_ARGS $TEMP_DIR \
        --password-file=/root/passwordfile \
        --exclude=dovecot-keywords --exclude=dovecot.index --exclude=dovecot.index.cache --exclude=dovecot.index.log --exclude=dovecot-uidlist \
        eccostorage.host.local::mail_backup \
        $DESTINATION/users_mail/ \
        1>> ${LOG_FILE}

# Fileserver
echo "Backing up Fileserver"
$RUNNER $NON_COMPRESS_ARGS $TEMP_DIR \
        --password-file=/root/passwordfile \
        --exclude=apps --exclude=FinePrint\ files --exclude=RECYCLER --exclude=My\ Pictures --exclude=Thumbs.db --exclude=Thumbs.db:encryptable \
        eccofileserver.host.local::file_backup \
        $DESTINATION/eccofileserver/ \
        1>> ${LOG_FILE}


# secure.host.com
echo "Backing up secure.host.com"
$RUNNER $COMPRESS_ARGS $TEMP_DIR \
        --rsh="$SSH_COMMAND $PUBLIC_KEY_PATH/secure.host.com_id_rsa" \
        secure@ukvm.host.com:~/ \
        $DESTINATION/secure.host.com \
        1>> ${LOG_FILE}

# images@ukvm.host.com
echo "Backing up images@ukvm.host.com"
$RUNNER $COMPRESS_ARGS $TEMP_DIR \
        --rsh="$SSH_COMMAND $PUBLIC_KEY_PATH/images.host.com_id_rsa" \
        images@ukvm.host.com:~/ \
        $DESTINATION/images.host.com \
        1>> ${LOG_FILE}

# eccolodge@ukvm.host.com
echo "Backing up eccolodge@ukvm.host.com"
$RUNNER $COMPRESS_ARGS $TEMP_DIR \
        --rsh="$SSH_COMMAND $PUBLIC_KEY_PATH/eccolodge.host.com_id_rsa" \
        eccolodge@ukvm.host.com:~/ \
        $DESTINATION/eccolodge.host.com \
        1>> ${LOG_FILE}

# ns.host.com
echo "Backing up ns.host.com"
$RUNNER $NO_INPLACE_COMPRESS_ARGS $TEMP_DIR \
        --rsh="ssh -i $PUBLIC_KEY_PATH/ns.host.com_id_dsa" \
        --exclude=ECCO_BACKUPS --exclude=.cpan \
        gevens@ns.host.com:~/ \
        $DESTINATION/ns.host.com \
        1>> ${LOG_FILE}


# Resmanager
echo "Backing up Resmanager"
$RUNNER $NON_COMPRESS_ARGS $TEMP_DIR \
        --exclude=Thumbs.db --exclude=Res\ Install --exclude=resmanager.mdb \
        /mnt/resmanager \
        $DESTINATION/ \
        1>> ${LOG_FILE}

RESULTS_SIZE=`stat -c %s ${LOG_FILE}`

if [ ${RESULTS_SIZE} -gt ${MAIL_SIZE} ];
then
    gzip ${LOG_FILE}
    uuencode ${LOG_FILE}.gz ${LOG_FILE}.gz | mail -s ${MAIL_SUBJECT} ${RECEIPIENT}
    rm -f ${LOG_FILE}.gz
else
    cat ${LOG_FILE} | mail -s ${MAIL_SUBJECT} ${RECEIPIENT}
    rm -f ${LOG_FILE}
fi

sleep 90
echo ${CURRENT_EPOCH_DATE} > ${BACKUP_DRIVE_MOUNT}/week_of_year
umount $BACKUP_DRIVE_MOUNT
rm -f /tmp/back_busy
exit
