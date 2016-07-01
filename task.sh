#!/bin/bash
# task
# 0:id 1:name:名称 2:group:组 3:file:程序文件 4:class:类名 5:method:方法名 6:params:参数 7:runtime:任务第一次运行时间 8:interval:间隔时长(秒)
# 9:stat_time:计划任务开始时间 10:end_time:计划任务结束时间 11:flag:标示  1：执行 2：暂停 12:state:状态 1:启用  2:停用 13:remarks:备注
declare -a task_arr
readonly run_start=1
readonly run_stop=2

closured(){
  local now_time=`date "+%s"`
  local OLD_IFS="$IFS"
  IFS=","
  local arr=(${task_arr[$1]//###/,})
  IFS="$OLD_IFS"
  local vals="${arr[0]}###${arr[1]}###${arr[2]}###${arr[3]}###${arr[4]}###${arr[5]}###${arr[6]}###${arr[7]}###${arr[8]}###${arr[9]}###${now_time}###${run_start}###${arr[12]}###${arr[13]}"
  task_arr[$1]=$vals
  $REDISEXEC set $2 "$vals"
}

while true
do
  for keys in `$REDISEXEC keys ${REDIS_KEYS}*`
  do
    #当前时间
    now_time=`date "+%s"`
    data=`$REDISEXEC get $keys`
    OLD_IFS="$IFS"
    IFS=","
    arr=(${data//###/,})
    IFS="$OLD_IFS"
    ids=${arr[0]}
    name=${arr[1]}
    group=${arr[2]}
    files=${arr[3]}
    class=${arr[4]}
    method=${arr[5]}
    params=${arr[6]}
    runtime=${arr[7]}
    interval=${arr[8]}
    start_time=${arr[9]}
    end_time=${arr[10]}
    flag=${arr[11]}
    state=${arr[12]}
    remarks=${arr[13]}
    space_time=`expr ${now_time} - ${end_time}`
    if [[ $runtime < $now_time ]] && [[ $space_time > $interval ]] && [[ $flag -eq $run_start ]] && [[ $state -eq 1 ]] && [[ -f $files ]];then
      vals="${ids}###${name}###${group}###${files}###${class}###${method}###${params}###${runtime}###${interval}###${now_time}###${end_time}###${run_stop}###${state}###${remarks}"
      task_arr[$ids]=$vals
      $REDISEXEC set $keys "$vals"
      $PHPEXEC $files $class $method $params "tid:$ids" && closured $ids $keys &
    fi
  done
  sleep 1
done
exit 0