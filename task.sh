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
   local now_time=`date "+%s"`
   read ids name files class method params runtime interval start_time end_time flag <<< `echo "${task_arr[$1]}" | awk -F'###' '{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11}'`
   local vals="${ids}###${name}###${files}###${class}###${method}###${params}###${runtime}###${interval}###${start_time}###${now_time}###${run_start}"
   task_arr[$1]=$vals
   echo -en $vals | $REDISEXEC -x set $2 &>/dev/null
}

while true
do
   for keys in `$REDISEXEC keys ${REDIS_KEYS}*`
   do
        #当前时间
        now_time=`date "+%s"`
        data=`$REDISEXEC get $keys`
        read ids name files class method params runtime interval start_time end_time flag <<< `echo $data | awk -F'###' '{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11}'`
        space_time=`expr ${now_time} - ${end_time}`
        if [[ $runtime -le $now_time ]] && [[ $space_time -ge $interval ]] && [[ $flag -eq $run_start ]]; then
                vals="${ids}###${name}###${files}###${class}###${method}###${params}###${runtime}###${interval}###${now_time}###${end_time}###${run_stop}"
                task_arr[$ids]=$vals
                echo -en $vals | $REDISEXEC -x set $keys &>/dev/null
                $PHPEXEC $files $class $method $params && closured $ids $keys &
        fi
  done
  sleep 1
done
exit 0