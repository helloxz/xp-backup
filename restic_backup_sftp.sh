#!/bin/bash
#resitc备份脚本
#####	restic备份脚本	#####
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/bin:/sbin:/usr/local/mysql/bin
export PATH

#导入环境变量
. data/.env

myip=$(hostname -I | awk '{print $1}')
new_hostname=${HOSTNAME}_${myip}

#restic备份
restic_backup(){
    cd /opt/xp-backup
	
    # 设置密码
    # echo ${RESTIC_PASSWORD} > ./data/.restic_pass
    
	#初始化存储,格式为：s3.us-west-002.backblazeb2.com/bucket_name/dir
    # S3_PATH=${AWS_S3_URL}/$AWS_BUCKET_NAME/${new_hostname}
	# sftp://user@[::1]:2222//srv/restic-repo
    restic -r sftp://${SFTP_USER}@${SFTP_HOST}:${SFTP_PORT}//${new_hostname} init
    # 运行清理
    ./tool.sh clear
	#备份数据
    # 需要备份的目录
    BACKUP_DIR="/opt/xp-backup/backup"
    restic -r sftp://${SFTP_USER}@${SFTP_HOST}:${SFTP_PORT}//${new_hostname} --verbose backup ${BACKUP_DIR}
}

# 运行
restic_backup