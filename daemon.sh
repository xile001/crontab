#!/bin/bash
#daemon

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export PATH

declare crontab_autoindex_file='./crontab_autoindex.log'
declare PROGRAM='crontab_autoindex.sh'

if [ -e $crontab_autoindex_file ] ; then
    touch $crontab_autoindex_file
fi

while true ; do
  sleep 10
  PRO_NOW=`ps aux | grep $PROGRAM | grep -v grep | wc -l`
  if [ $PRO_NOW -lt 1 ] ; then
      nohup ./$PROGRAM 2>/dev/null 1>&2 &
      date >> $crontab_autoindex_file
      echo "start" >> $crontab_autoindex_file
  fi

  PRO_STAT=`ps aux | grep $PROGRAM | grep T | grep -v grep | wc -l`
  if [ $PRO_STAT -gt 0 ] ; then
	killall -9 $PROGRAM
        sleep 2
        nohup ./$PROGRAM 2>/dev/null 1>&2 &
        date >> $crontab_autoindex_file
        echo "start" >> $crontab_autoindex_file
  fi
done
exit 0
