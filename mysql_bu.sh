#!/bin/sh
# Database Backup Script
# Written by J. Connor
#
# J. Connor is not responsible for any action of this script, use with care.

# Date format
DATE=`date +%m-%d-%Y_%H-%M`
# Backup Directory (Where you want to backup to)
#    DO NOT INCLUDE TRAILING /
BDIR=""
# Temp Directory (Where you want to store the files prior to moving them)
#    DO NOT INCLUDE TRAILING /
TDIR="/root/backup_$DATE"
# MySQL User
MUSER="backup"
# MySQL Pass
MPASS=""

# DO NOT EDIT BELOW THIS LINE (UNLESS YOU KNOW WHAT YOU ARE DOING)

#announce start
printf "Starting Database Backup!\r\n"
mkdir -p $TDIR/data
printf "Dumping Databases....\r\n"

databases=`/usr/bin/mysql -u $MUSER -p$MPASS -e "SHOW DATABASES;" | grep -Ev "(Database|information_schema)"`

for db in $databases; do

		DBFILE="$TDIR/data/$db.gz"

        printf "Dumping $db\r\n"
        /usr/bin/mysqldump --force --opt --user=$MUSER -p$MPASS --databases $db | gzip > $DBFILE
        printf "Finished $db\r\n"
done

printf "Creating Archive....\r\n"
cd $TDIR
tar -cjf $TDIR/$DATE.archive.tar.bz2 data
if [ "$?" -eq "0" ]; then
        printf "Archive Compressed.\r\n"
else
        printf "Backup Failed!\r\n"
        exit 1
fi
printf "Starting Move of Archive to $BDIR\r\n"
mv $TDIR/$DATE.archive.tar.bz2 $BDIR/
rm -rf $TDIR
printf "Move Completed!\r\n"
printf "Backup Completed!\r\n"
exit 0;