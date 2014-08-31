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
echo "Starting Database Backup!"
mkdir $TDIR
mkdir $TDIR/data
echo "Dumping Databases...."

databases=`/usr/bin/mysql -u $MUSER -p$MPASS -e "SHOW DATABASES;" | grep -Ev "(Database|information_schema)"`

for db in $databases; do

		DBFILE="$TDIR/data/$db.gz"

        echo "Dumping $db"
        /usr/bin/mysqldump --force --opt --user=$MUSER -p$MPASS --databases $db | gzip > $DBFILE
        echo "Finished $db"
done

echo "Creating Archive...."
cd $TDIR
tar -cjf $TDIR/$DATE.archive.tar.bz2 data
if [ "$?" -eq "0" ]; then
        echo "Archive Compressed."
else
        echo "Backup Failed!"
        exit 1
fi
echo "Starting Move of Archive to $BDIR"
mv $TDIR/$DATE.archive.tar.bz2 $BDIR/
rm -rf $TDIR
echo "Move Completed!"
echo "Backup Completed!"
exit 0;