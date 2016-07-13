#!/bin/bash
#global

#set -e -u

declare PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export PATH

#php 执行文件
readonly PHPEXEC=`which php`
#shell 执行文件
readonly SHELLEXEC=`which bash`
#redis 执行文件
readonly REDISEXEC='/usr/local/redis/src/redis-cli -h 127.0.0.1 -p 6379'
readonly REDIS_KEYS='crontab_task_'