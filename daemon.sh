#!/bin/bash
#daemon

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export PATH

readonly autoindex_file='./autoindex.log'
readonly PROGRAM='autoindex.sh'

if [ -e $autoindex_file ] ; then
  touch $autoindex_file
fi

while true ; do
  PRO_NOW=`ps aux | grep $PROGRAM | grep -v grep | wc -l`
  if [ $PRO_NOW -lt 1 ] ; then
    ./$PROGRAM
    date >> $autoindex_file
    echo "start" >> $autoindex_file
  fi

  PRO_STAT=`ps aux | grep $PROGRAM | grep T | grep -v grep | wc -l`
  if [ $PRO_STAT -gt 0 ] ; then
    killall -9 $PROGRAM
    sleep 2
    ./$PROGRAM
    date >> $autoindex_file
    echo "start" >> $autoindex_file
  fi
  sleep 60
done
exit 0