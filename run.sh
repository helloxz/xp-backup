#!/bin/bash

# 导入定时任务
run(){
    # 检查./data/.env是否存在
    if [ ! -f "./data/.env" ]; then
        # 不存在，则复制一个
        cp .env.example ./data/.env
    fi
    # 导入环境变量
    . ./data/.env

    # 检查restic文件是否存在
    if [ ! -f "./data/.restic_pass" ]; then
        # 不存在，则设置
        # 设置密码
        echo ${RESTIC_PASSWORD} > ./data/.restic_pass
        export RESTIC_PASSWORD_FILE=./data/.restic_pass
    fi

    # 查看密码文件的内容，判断是否为空内容
    if [ ! -s "./data/.restic_pass" ]; then
        echo 'Please modify the .env file and set the RESTIC_PASSWORD variable.'
        exit
    fi

    
    # 写入定时任务
    rm -rf /etc/cron.d/xp-backup
    # 如果CRON_TIME_MYSQL不为空才写入
    if [ ! -z ${CRON_TIME_MYSQL} ]; then
        echo "${CRON_TIME_MYSQL} root cd /opt/xp-backup && ./backup_mysql.sh >> /var/log/xp-backup.log 2>&1" >> /etc/cron.d/xp-backup
    fi
    # echo "${CRON_TIME_MYSQL} root cd /opt/xp-backup && ./backup_mysql.sh >> /var/log/xp-backup.log 2>&1" >> /etc/cron.d/xp-backup
    # 判断类型是s3还是sftp
    if [ ${STORAGE_TYPE} == 'sftp' ]; then
        echo "${CRON_TIME_DIR} root cd /opt/xp-backup && ./restic_backup_sftp.sh >> /var/log/xp-backup.log 2>&1" >> /etc/cron.d/xp-backup
    else
        echo "${CRON_TIME_DIR} root cd /opt/xp-backup && ./restic_backup.sh >> /var/log/xp-backup.log 2>&1" >> /etc/cron.d/xp-backup
    fi
    # echo "${CRON_TIME_DIR} root cd /opt/xp-backup && ./restic_backup.sh >> /var/log/xp-backup.log 2>&1" >> /etc/cron.d/xp-backup
    # 赋予执行权限
    chmod 0644 /etc/cron.d/xp-backup
    # 添加计划任务
    crontab /etc/cron.d/xp-backup
    # 启动计划任务
    /etc/init.d/cron start
    # 查看日志
    touch /var/log/xp-backup.log
    tail -f /var/log/xp-backup.log
}

# 运行
run