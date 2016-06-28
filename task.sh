#!/bin/bash
# task
# id name:名称 group:组 file:程序文件 class:类名 method:方法名 params:参数 runtime:任务第一次运行时间 interval:间隔时长(秒)
# stat_time:计划任务开始时间 end_time:计划任务结束时间 flag:标示  1：执行 2：暂停 status:状态 1:启用  2:停用 remarks:备注
declare -a task_arr
readonly run_start=1
readonly run_stop=2

closured(){
   local now_time=`date "+%s"`
   read ids1 name1 group1 files1 class1 method1 params1 runtime1 interval1 start_time1 end_time1 flag1 status1 remarks1 <<< `echo "${task_arr[$1]}" | awk -F'###' '{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14}'`
   local vals="${ids1}###${name1}###${group1}###${files1}###${class1}###${method1}###${params1}###${runtime1}###${interval1}###${now_time1}###${end_time1}###${run_start}###${status1}###${remarks1}"
   task_arr[$1]=$vals
   echo -en $vals | $REDISEXEC -x set $2
}

while true
do
   for keys in `$REDISEXEC keys ${REDIS_KEYS}*`
   do
        #当前时间
        now_time=`date "+%s"`
        data=`$REDISEXEC get $keys`
        read ids name group files class method params runtime interval start_time end_time flag status remarks <<< `echo $data | awk -F'###' '{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14}'`
        space_time=`expr ${now_time} - ${end_time}`
        if [[ $runtime -le $now_time ]] && [[ $space_time -ge $interval ]] && [[ $flag -eq $run_start ]] && [[ $status -eq 1 ]];then
                vals="${ids}###${name}###${group}###${files}###${class}###${method}###${params}###${runtime}###${interval}###${now_time}###${end_time}###${run_stop}###${status}###${remarks}"
                task_arr[$ids]=$vals
                echo -en $vals | $REDISEXEC -x set $keys
                $PHPEXEC $files $class $method $params && closured $ids $keys &
        fi
    done
    sleep 1
done
exit 0