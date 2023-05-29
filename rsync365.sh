#!/bin/ksh
# @(#) Incremental rsync backup rotation & retention management
# $Id: rsync365.sh,v 1.10 2022/01/23 06:02:03 root Exp $
# 30/12/2016 - written by Marc O. Gloor <marc.gloor@alumni.nus.edu.sg>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA
#
# Incremental rsync backup rotation & retention management
#  daily, weekly, monthly, yearly backup rotation using hard-links over rsync
#
# Underlying upstream sources used (baselined early 2017):
#  https://gist.github.com/timblack1/a3170dbbbbbd1c2a44fe#file-webfaction_rsync-sh
#  http://www.noah.org/engineering/src/shell/rsync_backup
#
# GFS backup rotation & retention period:
#  Keep daily incremental backups for 7 days retention
#  Keep weekly incremental backups for 4 weeks retention
#  Keep monthly incremental backups for 11 Months retention
#  Keep yearly incremental backups for 10 years retention
#
# This maintains a one week rotating backup. This will normalize permissions on
# all files and directories on backups. It has happened that someone removed
# owner write permissions on some files, thus breaking the backup process. This
# prevents that from happening. All this permission changing it tedious, but it
# eliminates any doubts. I could have done this with "chmod -R +X", but I
# wanted to explicitly set the permission bits. Ideally this script will be 
# executed on a filesystem located on a RAID volume. 
#
 
SYSLOG="logger -p local3.info -t "$0""
$SYSLOG "backup session (pid $$) initiated"
CURRDATE=`date "+%d-%b-%Y_%H:%M:%S"`
PERMS_DIR=755
PERMS_FILE=644
RSYNC_OPTS="-al --delete -q"    # quite mode
#RSYNC_OPTS="-al --delete -v"   # verbose mode

usage() {
    echo ""
    echo "  rsync365.sh"
    echo "   incremental rsync backup rotation & retention management"
    echo ""
    echo "  Usage:"
    echo "   rsync365.sh SOURCE_PATH BACKUP_PATH"
    echo "   rsync365.sh - without args will display curr dir bkp listing"
    echo ""
    echo "  Syntax:"
    echo "   SOURCE_PATH is a local dir to backup"
    echo "   BACKUP_PATH is the storage location of the backup set"
    echo ""
}

SOURCE_PATH=$1
BACKUP_PATH=$2

stats () {
  echo ""
  for DEST in daily weekly monthly yearly; do
    if [ -d ./$DEST ]; then
      str="$DEST backups:"
      echo $str | awk '{print toupper($0)}'
      i=0
      file=$(ls -A $DEST|head -n 1|awk '{print substr($0,1, length($0)-2)}')
    
      while [ -f ./$DEST/$file.$i/BACKUP_* ] ; do
        echo -n " $file.$i: " && cat ./$DEST/$file.$i/BACKUP_* | \
         head -n 1
        (( i++ ))
      done
    fi
    echo ""
  done
  exit
}

# Retention CHECK MOMENTAN NOT IN USE
retention_check () {
  # Remove weekly/monthly/yearly backups older than retention time
  echo "EXPIRED RETENTION:" 
  # Find weekly backups older than 28 days
  find . -type d -name "weekly" -mtime +28 -exec $(echo "weekly: " && ls -A) {} \;
  # Find monthly backups older than 62 days
  find . -type d -name "monthly" -mtime +62 -exec $(echo "monthly: " && ls -A) {} \;
  # Find yearly backups older than 365 days
  find . -type d -name "yearly" -mtime +365 -exec $(echo "yearly :" s -A) {} \;
  exit 1
}

version () {
 echo "$(basename $0) / \$Revision: 1.10 $"
}

if test $# -eq 0; then
  stats
 elif [ -z $SOURCE_PATH ] ; then
  usage
  exit 1
 elif [ -z $BACKUP_PATH ] ; then
  usage
  exit 1
fi

timer () {
    
    if [[ $# -eq 0 ]]; then
        echo $(date '+%s')
    else
        stime=$1
        etime=$(date '+%s')

        if [[ -z "$stime" ]]; then stime=$etime; fi

        dt=$((etime - stime))
        ds=$((dt % 60))
        dm=$(((dt / 60) % 60))
        dh=$((dt / 3600))
        printf '%d:%02d:%02d' $dh $dm $ds
    fi
}

tmr=$(timer)
SOURCE_BASE=`basename $SOURCE_PATH`

if [ ! -d $BACKUP_PATH ] ; then
    echo "creating incremental backup logrotation directory structure"
    $SYSLOG "creating incremental backup logrotation directory structure"
    mkdir $BACKUP_PATH/    

    for DEST in daily weekly monthly yearly; do 
      mkdir $BACKUP_PATH/$DEST 
    done    
fi

if [ -d $BACKUP_PATH ] ; then
    $SYSLOG "creating incremental backup logrotation directory structure"

    for DEST in daily weekly monthly yearly; do 
      mkdir $BACKUP_PATH/$DEST >/dev/null 2>&1
    done    
fi

version
echo "performing incremental logrotation backup"

POSTFIX=0
while [ $POSTFIX -le 6 ]
do
	if [ ! -d $BACKUP_PATH/daily/$SOURCE_BASE.$POSTFIX ] ; then
		mkdir $BACKUP_PATH/daily/$SOURCE_BASE.$POSTFIX
	fi 
	POSTFIX=`expr $POSTFIX + 1`
done

POSTFIX=0
while [ $POSTFIX -le 4 ]
do
	if [ ! -d $BACKUP_PATH/weekly/$SOURCE_BASE.$POSTFIX ] ; then
		mkdir $BACKUP_PATH/weekly/$SOURCE_BASE.$POSTFIX
	fi 
	POSTFIX=`expr $POSTFIX + 1`
done

POSTFIX=0
while [ $POSTFIX -le 10 ]
do
	if [ ! -d $BACKUP_PATH/monthly/$SOURCE_BASE.$POSTFIX ] ; then
		mkdir $BACKUP_PATH/monthly/$SOURCE_BASE.$POSTFIX
	fi 
	POSTFIX=`expr $POSTFIX + 1`
done

POSTFIX=0
while [ $POSTFIX -le 9 ]
do
	if [ ! -d $BACKUP_PATH/yearly/$SOURCE_BASE.$POSTFIX ] ; then
		mkdir $BACKUP_PATH/yearly/$SOURCE_BASE.$POSTFIX
	fi 
	POSTFIX=`expr $POSTFIX + 1`
done

normalize () {
    echo "normalizing file permissions"
    find $BACKUP_PATH/$1/$SOURCE_BASE.0 -type d -exec chmod $PERMS_DIR {} \;
    find $BACKUP_PATH/$1/$SOURCE_BASE.0 -type f -exec chmod $PERMS_FILE {} \;
}

timestamp () {
	# Ignore error code 24, "rsync warning: some files vanished before they could be transferred".
	if [ $RSYNC_EXIT_STATUS = 24 ] ; then
  	  RSYNC_EXIT_STATUS=0
	fi

	# Create a timestamp file to show when backup process completed successfully.
	if [ $RSYNC_EXIT_STATUS = 0 ] ; then
	    rm -f $BACKUP_PATH/$1/$SOURCE_BASE.0/BACKUP_ERROR
	    echo $CURRDATE > $BACKUP_PATH/$1/$SOURCE_BASE.0/BACKUP_TIMESTAMP
	else # Create a timestamp if there was an error.
	    rm -f $BACKUP_PATH/$1/$SOURCE_BASE.0/BACKUP_TIMESTAMP
 	    echo "rsync failed" > $BACKUP_PATH/$1/$SOURCE_BASE.0/BACKUP_ERROR
 	    echo $CURRDATE >> $BACKUP_PATH/$1/$SOURCE_BASE.0/BACKUP_ERROR
 	    #echo $RSYNC_EXIT_STATUS >> $BACKUP_PATH/$1/$SOURCE_BASE.0/BACKUP_ERROR
	fi
}

# TODO All these find operations to clean up permissions is going to add a lot
# of overhead as the backup set gets bigger. At 100 GB it's not a big deal. The
# correct thing would be to have an exception based system where I correct
# permissions when/if they cause a problem.

rm -rf $BACKUP_PATH/daily/$SOURCE_BASE.6
mv     $BACKUP_PATH/daily/$SOURCE_BASE.5 $BACKUP_PATH/daily/$SOURCE_BASE.6
mv     $BACKUP_PATH/daily/$SOURCE_BASE.4 $BACKUP_PATH/daily/$SOURCE_BASE.5
mv     $BACKUP_PATH/daily/$SOURCE_BASE.3 $BACKUP_PATH/daily/$SOURCE_BASE.4
mv     $BACKUP_PATH/daily/$SOURCE_BASE.2 $BACKUP_PATH/daily/$SOURCE_BASE.3
mv     $BACKUP_PATH/daily/$SOURCE_BASE.1 $BACKUP_PATH/daily/$SOURCE_BASE.2
cp -al $BACKUP_PATH/daily/$SOURCE_BASE.0 $BACKUP_PATH/daily/$SOURCE_BASE.1

normalize daily 
rsync $RSYNC_OPTS $SOURCE_PATH/ $BACKUP_PATH/daily/$SOURCE_BASE.0/
RSYNC_EXIT_STATUS=$?
timestamp daily

# On last weekday, copy today's dir into the weekly dir folder (1-7: 1 is Mon)
if [ $(date +%u) -eq 1 ] ; then
    echo "weekly backup stored & archived"
    $SYSLOG "weekly backup stored & archived"

    rm -rf $BACKUP_PATH/weekly/$SOURCE_BASE.4
    mv     $BACKUP_PATH/weekly/$SOURCE_BASE.3 $BACKUP_PATH/weekly/$SOURCE_BASE.4
    mv     $BACKUP_PATH/weekly/$SOURCE_BASE.2 $BACKUP_PATH/weekly/$SOURCE_BASE.3
    mv     $BACKUP_PATH/weekly/$SOURCE_BASE.1 $BACKUP_PATH/weekly/$SOURCE_BASE.2
    cp -al $BACKUP_PATH/weekly/$SOURCE_BASE.0 $BACKUP_PATH/weekly/$SOURCE_BASE.1

    normalize weekly
    rsync $RSYNC_OPTS $SOURCE_PATH/ $BACKUP_PATH/weekly/$SOURCE_BASE.0/
    RSYNC_EXIT_STATUS=$?  
    timestamp weekly
fi

# On 1st day of the month, copy today's dir into the monthly dir folder
if [ $(date +%d) -eq 1 ] ; then
    echo "monthly backup stored & archived"
    $SYSLOG "monthly backup stored & archived"

    rm -rf $BACKUP_PATH/monthly/$SOURCE_BASE.10
    mv     $BACKUP_PATH/monthly/$SOURCE_BASE.9 $BACKUP_PATH/monthly/$SOURCE_BASE.10
    mv     $BACKUP_PATH/monthly/$SOURCE_BASE.8 $BACKUP_PATH/monthly/$SOURCE_BASE.9
    mv     $BACKUP_PATH/monthly/$SOURCE_BASE.7 $BACKUP_PATH/monthly/$SOURCE_BASE.8
    mv     $BACKUP_PATH/monthly/$SOURCE_BASE.6 $BACKUP_PATH/monthly/$SOURCE_BASE.7
    mv     $BACKUP_PATH/monthly/$SOURCE_BASE.5 $BACKUP_PATH/monthly/$SOURCE_BASE.6
    mv     $BACKUP_PATH/monthly/$SOURCE_BASE.4 $BACKUP_PATH/monthly/$SOURCE_BASE.5
    mv     $BACKUP_PATH/monthly/$SOURCE_BASE.3 $BACKUP_PATH/monthly/$SOURCE_BASE.4
    mv     $BACKUP_PATH/monthly/$SOURCE_BASE.2 $BACKUP_PATH/monthly/$SOURCE_BASE.3
    mv     $BACKUP_PATH/monthly/$SOURCE_BASE.1 $BACKUP_PATH/monthly/$SOURCE_BASE.2
    cp -al $BACKUP_PATH/monthly/$SOURCE_BASE.0 $BACKUP_PATH/monthly/$SOURCE_BASE.1

    normalize monthly
    rsync $RSYNC_OPTS $SOURCE_PATH/ $BACKUP_PATH/monthly/$SOURCE_BASE.0/
    RSYNC_EXIT_STATUS=$?  
    timestamp monthly

fi

# On 1st day of the year, copy today's dir into the yearly dir folder
if [ $(date +%j) -eq 1 ] ; then
    echo "yearly backup stored & archived"
    $SYSLOG "yearly backup stored & archived"

    rm -rf $BACKUP_PATH/yearly/$SOURCE_BASE.9
    mv     $BACKUP_PATH/yearly/$SOURCE_BASE.8 $BACKUP_PATH/yearly/$SOURCE_BASE.9
    mv     $BACKUP_PATH/yearly/$SOURCE_BASE.7 $BACKUP_PATH/yearly/$SOURCE_BASE.8
    mv     $BACKUP_PATH/yearly/$SOURCE_BASE.6 $BACKUP_PATH/yearly/$SOURCE_BASE.7
    mv     $BACKUP_PATH/yearly/$SOURCE_BASE.5 $BACKUP_PATH/yearly/$SOURCE_BASE.6
    mv     $BACKUP_PATH/yearly/$SOURCE_BASE.4 $BACKUP_PATH/yearly/$SOURCE_BASE.5
    mv     $BACKUP_PATH/yearly/$SOURCE_BASE.3 $BACKUP_PATH/yearly/$SOURCE_BASE.4
    mv     $BACKUP_PATH/yearly/$SOURCE_BASE.2 $BACKUP_PATH/yearly/$SOURCE_BASE.3
    mv     $BACKUP_PATH/yearly/$SOURCE_BASE.1 $BACKUP_PATH/yearly/$SOURCE_BASE.2
    cp -al $BACKUP_PATH/yearly/$SOURCE_BASE.0 $BACKUP_PATH/yearly/$SOURCE_BASE.1

    normalize yearly
    rsync $RSYNC_OPTS $SOURCE_PATH/ $BACKUP_PATH/yearly/$SOURCE_BASE.0/
    RSYNC_EXIT_STATUS=$?  
    timestamp yearly

fi

printf 'backup completed (job run: %s)\n' $(timer $tmr)
$SYSLOG "backup session (pid $$) terminated"
cd $BACKUP_PATH; stats
exit $RSYNC_EXIT_STATUS
#EOF

