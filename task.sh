#!/bin/bash
# task
declare -a task_arr
declare task_file="${ROOT_PATH}/task.db"
declare run_start=1
declare run_stop=2
declare access_file="${ROOT_PATH}/access.log"
if [ ! -e $access_file ];then
   touch $access_file
fi
closured(){
   local data=${task_arr[$1]}
   local now_time=`date "+%s"`
   local ids=`echo $LINE | awk -F'###' '{print $1}'`
   local name=`echo $LINE | awk -F'###' '{print $2}'`
   local files=`echo $LINE | awk -F'###' '{print $3}'`
   local class=`echo $LINE | awk -F'###' '{print $4}'`
   local method=`echo $LINE | awk -F'###' '{print $5}'`
   local params=`echo $LINE | awk -F'###' '{print $6}'`
   local runtime=`echo $LINE | awk -F'###' '{print $7}'`
   local interval=`echo $LINE | awk -F'###' '{print $8}'`
   local start_time=`echo $LINE | awk -F'###' '{print $9}'`
   local end_time=`echo $LINE | awk -F'###' '{print $10}'`
   local flag=`echo $LINE | awk -F'###' '{print $11}'`
   local vals="${ids}###${name}###${files}###${class}###${method}###${params}###${runtime}###${interval}###${start_time}###${now_time}###${run_start}"

   task_arr[$1]=$vals

   usleep 10000

   sed -i "/^${1}###/c $vals" $task_file
   
   ${DB_EXEC} -e "update ${DB_DATABASE}.task set end_time='${now_time}' where id='${1}'"
}

while true
do
  #当前时间
  now_time=`date "+%s"`
  tail -n +2 $task_file | while read LINE
   do
      runtime=`echo $LINE | awk -F'###' '{print $7}'`
      interval=`echo $LINE | awk -F'###' '{print $8}'`
      end_time=`echo $LINE | awk -F'###' '{print $10}'`
      flag=`echo $LINE | awk -F'###' '{print $11}'`
      space_time=`expr ${now_time} - ${end_time}`

      if [ $runtime -le $now_time -a $space_time -ge $interval -a $flag -eq $run_start ] ; then

         ids=`echo $LINE | awk -F'###' '{print $1}'`
         name=`echo $LINE | awk -F'###' '{print $2}'`
         files=`echo $LINE | awk -F'###' '{print $3}'`
         class=`echo $LINE | awk -F'###' '{print $4}'`
         method=`echo $LINE | awk -F'###' '{print $5}'`
         params=`echo $LINE | awk -F'###' '{print $6}'`
         start_time=`echo $LINE | awk -F'###' '{print $9}'`
         now_time=`date "+%s"`
         vals="${ids}###${name}###${files}###${class}###${method}###${params}###${runtime}###${interval}###${now_time}###${end_time}###${run_stop}"

         task_arr[$ids]=$vals

         usleep 10000

         sed -i "/^${ids}###/c $vals" $task_file

         ${DB_EXEC} -e "update ${DB_DATABASE}.task set stat_time='${now_time}' where id='${ids}'"

         nohup $PHPEXEC $files $class $method $params >>$access_file 2>&1 && closured $ids &
      fi
   done
   sleep 1
done
exit 0