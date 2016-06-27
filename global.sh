#!/bin/bash
#global

#set -e -u

declare PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export PATH

# 当前路径
export ROOT_PATH=`pwd`
#php 执行文件
declare PHPEXEC=`which php`
#redis 执行文件
declare REDISEXEC='/usr/local/redis/src/redis-cli -h 127.0.0.1 -p 6379'
declare REDIS_KEYS='crontab_task_'