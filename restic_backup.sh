#!/bin/bash
#resitc备份脚本
#####	restic备份脚本	#####
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/bin:/sbin:/usr/local/mysql/bin
export PATH

#导入环境变量
. data/.env

myip=$(hostname -I | awk '{print $1}')
new_hostname=${HOSTNAME}_${myip}

export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
export RESTIC_PASSWORD_FILE=./data/.restic_pass

#restic备份
restic_backup(){
    cd /opt/xp-backup
	
    # 设置密码
    # echo ${RESTIC_PASSWORD} > ./data/.restic_pass
    
	#初始化存储,格式为：s3.us-west-002.backblazeb2.com/bucket_name/dir
    S3_PATH=${AWS_S3_URL}:/$AWS_BUCKET_NAME/${new_hostname}
	restic -r s3:${S3_PATH} init
	#备份数据
    # 需要备份的目录
    BACKUP_DIR="/opt/xp-backup/backup"
    restic ${EXCLUDE_DIRS} -r s3:${S3_PATH} --verbose backup ${BACKUP_DIR}
	
}

# 运行
restic_backup