#!/bin/bash
# task
# ids:id name:名称 pid:主ID group:组 classify:类型 files:程序文件 class:类名 method:方法名 params:参数 int_runtime:任务第一次运行时间 year:年 month:月 week:周 day:日 hour:时 minute:分 second:秒
# interval_seconds 间隔时间（s） start:计划任务开始时间 end:计划任务结束时间 flag:标示  1：执行 2：暂停 status:状态 1:启用  2:停用 nums:执行次数 remarks:备注
readonly run_start=1
readonly run_stop=2
readonly step=1

closured(){
  local now_time=`date "+%s"`
  $REDISEXEC hmset $1 end "$now_time" flag "$run_start" &>/dev/null
}
subtask(){
  local -a arrs
  local ids=''
  local name=''
  local group=''
  local classify=''
  local files=''
  local class=''
  local method=''
  local params=''
  local flag=''
  local suffix=''
  local num=0
  local run_status=0
  local interval=0
  local now_time=`date "+%s"`
  local pid=${1##*p}
  #有序集合
  for key in `$REDISEXEC zrange ${REDIS_KEYS}${ip32_addr}zps_${pid} 0 -1`
  do
    arrs=(`$REDISEXEC hmget $key ids name group classify files class method params flag status nums interval_seconds`)
    ids=${arrs[0]}
    name=${arrs[1]}
    group=${arrs[2]}
    classify=${arrs[3]}
    files=${arrs[4]}
    class=${arrs[5]}
    method=${arrs[6]}
    params=${arrs[7]}
    flag=${arrs[8]}
    run_status=${arrs[9]}
    num=${arrs[10]}
    interval=${arrs[11]}
    suffix=${files##*.}
    if [[ $flag -eq $run_start && $run_status -eq 1 && -f $files ]];then
      num=$[num + 1]
      now_time=`date "+%s"`
      $REDISEXEC hmset $key start "$now_time" nums "$num" flag "$run_stop" &>/dev/null
      case $params in
        0)
          params="tid:s$ids tinterval:s$interval tgroup_name:$group tclassify:$classify tname:$name ip32_addr:$ip32_addr"
          ;;
        *)
          params="$params tid:s$ids tinterval:s$interval tgroup_name:$group tclassify:$classify tname:$name ip32_addr:$ip32_addr"
      esac
      case $suffix in
        php)
          $PHPEXEC $files $class $method $params && closured $key
          ;;
        sh)
          $SHELLEXEC $files $params && closured $key
          ;;
        *)
          echo "php or sh"
          exit 1
      esac
    fi
  done
  now_time=`date "+%s"`
  $REDISEXEC hmset $1 end "$now_time" flag "$run_start" &>/dev/null
}

while true
do
  for keys in `$REDISEXEC zrevrange ${REDIS_KEYS}${ip32_addr}zp 0 -1`
  do
    #当前时间
    now_time=`date "+%s"`
    now_date_arr=(`date "+%Y %m %u %d %H %M %S"`)
    arr=(`$REDISEXEC hmget $keys ids name group classify files class method params int_runtime year month week day hour minute second interval_seconds start end flag status nums`)
    ids=${arr[0]}
    name=${arr[1]}
    group=${arr[2]}
    classify=${arr[3]}
    files=${arr[4]}
    class=${arr[5]}
    method=${arr[6]}
    params=${arr[7]}
    int_runtime=${arr[8]}
    year=${arr[9]}
    month=${arr[10]}
    week=${arr[11]}
    day=${arr[12]}
    hour=${arr[13]}
    minute=${arr[14]}
    second=${arr[15]}
    start_time=${arr[17]}
    end_time=${arr[18]}
    flag=${arr[19]}
    run_status=${arr[20]}
    num=${arr[21]}
    suffix=${files##*.}
    state=0
    interval=''

    if [[ $run_status -eq 2 ]];then
      continue
    fi

    case $classify in
      1)
        #轮循
        interval=${arr[16]}
        space_time=$[now_time - end_time]
        delayed_time=$[start_time + 2 * interval]
        if [[ $interval -eq 0 || $space_time -ge $interval || $end_time -gt $delayed_time ]];then
          state=1
        fi
        interval="s$interval"
        ;;
      2)
        #定时
        if [[ $year != ${now_date_arr[0]} && $year != '0000' ]];then
          state=0
        elif [[ $year == ${now_date_arr[0]} ]];then
          state=1
          interval="${year}y"
        else
          state=2
        fi

        if [[ $state -eq 1 ]];then
          if [[ $month == ${now_date_arr[1]} ]];then
            state=1
            interval="${interval}m$month"
          else
            state=0
          fi
        elif [[ $state -eq 2 ]];then
          if [[ $month != ${now_date_arr[1]} && $month != '00' ]];then
            state=0
          elif [[ $month == ${now_date_arr[1]} ]];then
            state=1
            interval="${interval}m$month"
          else
            state=2
          fi
        else
          state=0
        fi

        if [[ $state -eq 1 ]];then
          if [[ $week == ${now_date_arr[2]} ]];then
            state=1
            interval="${interval}w$week"
          else
            state=0
          fi
        elif [[ $state -eq 2 ]];then
          if [[ $week != ${now_date_arr[2]} && $week != '0' ]];then
            state=0
          elif [[ $week == ${now_date_arr[2]} ]];then
            state=1
            interval="${interval}w$week"
          else
            state=2
          fi
        else
          state=0
        fi

        if [[ $state -eq 1 ]];then
          if [[ $day == ${now_date_arr[3]} ]];then
            state=1
            interval="${interval}d$day"
          else
            state=0
          fi
        elif [[ $state -eq 2 ]];then
          if [[ $day != ${now_date_arr[3]} && $day != '00' ]];then
            state=0
          elif [[ $day == ${now_date_arr[3]} ]];then
            state=1
            interval="${interval}d$day"
          else
            state=2
          fi
        else
          state=0
        fi

        if [[ $state -eq 1 ]];then
          if [[ $hour == ${now_date_arr[4]} ]];then
            state=1
            interval="${interval}h$hour"
          else
            state=0
          fi
        elif [[ $state -eq 2 ]];then
          if [[ $hour != ${now_date_arr[4]} && $hour != '00' ]];then
            state=0
          elif [[ $hour == ${now_date_arr[4]} ]];then
            state=1
            interval="${interval}h$hour"
          else
            state=2
          fi
        else
          state=0
        fi

        if [[ $state -eq 1 ]];then
          if [[ $minute == ${now_date_arr[5]} ]];then
            state=1
            interval="${interval}i$minute"
          else
            state=0
          fi
        elif [[ $state -eq 2 ]];then
          if [[ $minute != ${now_date_arr[5]} && $minute != '00' ]];then
            state=0
          elif [[ $minute == ${now_date_arr[5]} ]];then
            state=1
            interval="${interval}i$minute"
          else
            state=2
          fi
        else
          state=0
        fi

        if [[ $state -eq 1 ]];then
          if [[ $second == ${now_date_arr[6]} ]];then
            state=1
            interval="${interval}s$second"
          else
            state=0
          fi
        elif [[ $state -eq 2 ]];then
          if [[ $second != ${now_date_arr[6]} && $second != '00' ]];then
            state=0
          elif [[ $second == ${now_date_arr[6]} ]];then
            state=1
            interval="${interval}s$second"
          elif [[ $year == '0000' && $month == '00' && $week == '0' && $day == '00' && $hour == '00' && $minute == '00' && $second == '00' ]];then
            state=1
            interval="${interval}s$second"
          else
            state=2
          fi
        else
          state=0
        fi
        ;;
    esac
    #echo `date "+%Y %m %u %d %H %M %S"`
    #echo "$classify $interval $int_runtime $now_time $state $flag $run_start $run_status $files"
    if [[ $int_runtime -le $now_time && $state -eq 1 && $flag -eq $run_start && -f $files ]];then
      num=$[num + 1]
      now_time=`date "+%s"`
      $REDISEXEC hmset $keys start "$now_time" nums "$num" flag "$run_stop" &>/dev/null
      case $params in
        0)
          params="tid:p$ids tinterval:$interval tgroup_name:$group tclassify:$classify tname:$name ip32_addr:$ip32_addr"
          ;;
        *)
          params="$params tid:p$ids tinterval:$interval tgroup_name:$group tclassify:$classify tname:$name ip32_addr:$ip32_addr"
      esac
      case $suffix in
        php)
          $PHPEXEC $files $class $method $params && subtask $keys &
          ;;
        sh)
          $SHELLEXEC $files $params && subtask $keys &
          ;;
        jar)
          $JAVAEXEC $files $class $method $params && subtask $keys &
          ;;
        *)
          echo "php or sh"
          exit 1
      esac
    fi
  done
  sleep $step
done
exit 0