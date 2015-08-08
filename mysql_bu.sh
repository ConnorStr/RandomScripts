#!/bin/sh
# The MIT License (MIT)
# 
# Copyright (c) 2014-2015 Connor Strandt
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

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