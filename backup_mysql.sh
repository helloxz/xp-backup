#!/bin/bash
#####	MySQL备份脚本	#####
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/bin:/sbin:/usr/local/mysql/bin
export PATH

#导入环境变量
. data/.env

BASEDIR='/opt/xp-backup'
#当前时间
ctime=$(date +%Y%m%d)
#上一个月的时间，精确到月份就行了
ptime=$(date -d "last month" +%Y%m)


#开始备份数据库
backup_mysql(){
	# 进入运行目录
    cd ${BASEDIR}
    # 创建备份目录
    MYSQL_BACKUP_DIR=${BASEDIR}/backup/mysql/${ctime}
    mkdir -p ${MYSQL_BACKUP_DIR}
    # 使用mydumper备份数据库
    mydumper -h ${DB_HOST} -u ${DB_USER} -p ${DB_PASSWORD} --regex "^(?!(${DB_EXCLUDE}))" -o ${MYSQL_BACKUP_DIR} -c
	
}

#删除上个月的数据
delete_expire_data(){
	rm -rf ${BASEDIR}/backup/mysql/${ptime}*
}

backup_mysql && delete_expire_data