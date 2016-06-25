#!/bin/bash
#global

#set -e -u

declare PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export PATH

# 当前路径
export ROOT_PATH=`pwd`
#php 执行文件
declare PHPEXEC=`which php`
# 载入数据库配置
source ${ROOT_PATH}/config/database.sh
