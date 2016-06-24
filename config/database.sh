#!/bin/bash
#database config
set -e -u
declare DB_HOST="127.0.0.1"
declare DB_UNAME="demo"
declare DB_PWD="123456"
declare DB_PORT="3306"
declare DB_DATABASE="demo"

# mysql客户端路径
declare MYSQL_CLIENT_PATH='/usr/local/mysql/bin/mysql'

# mysql执行
declare DB_EXEC="${MYSQL_CLIENT_PATH} -h${DB_HOST} -u${DB_UNAME} -p${DB_PWD}"
