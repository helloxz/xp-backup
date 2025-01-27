#!/bin/bash
#####	name:用于查看备份列表	#####

#####	restic备份脚本	#####
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/bin:/sbin:/usr/local/mysql/bin
export PATH

# 进入运行目录
cd /opt/xp-backup
#导入环境变量
. data/.env

export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
# 设置密码
echo ${RESTIC_PASSWORD} > ./data/.restic_pass
export RESTIC_PASSWORD_FILE=./data/.restic_pass

myip=$(hostname -I | awk '{print $1}')
new_hostname=${HOSTNAME}_${myip}

#获取参数1
ARG=$1
#获取参数2
ARG2=$2
#获取参数3
ARG3=$3

#初始化存储,格式为：s3.us-west-002.backblazeb2.com/bucket_name/dir
S3_PATH=${AWS_S3_URL}/$AWS_BUCKET_NAME/${new_hostname}
S3_CONN=s3:${S3_PATH}
# SFTP 
SFTP_CONN=sftp://${SFTP_USER}@${SFTP_HOST}:${SFTP_PORT}/./${new_hostname}

# 根据STORAGE_TYPE选择存储类型
case ${STORAGE_TYPE} in
	's3')
		# S3
		CONN=$S3_CONN
		SHELL_NAME='restic_backup.sh'
	;;
	'sftp')
		# SFTP
		CONN=$SFTP_CONN
		SHELL_NAME='restic_backup_sftp.sh'
	;;
	*)
		CONN=$S3_CONN
		SHELL_NAME='restic_backup.sh'
esac

case ${ARG} in
	'list')
		#查看备份列表
		restic -r ${CONN} snapshots
	;;
	'restore')
		#恢复备份
		restic -r ${CONN} restore ${ARG2} --target ${ARG3}
	;;
	'clear')
		#解除锁定
		restic -r ${CONN} unlock
		# 清理快照，并保存最后30个，如果保留3个月，则用--keep-monthly 3
		restic -r ${CONN} forget --prune --keep-last 60
	;;
	'backup')
		bash ${SHELL_NAME}
	;;
	*)
		echo 'args not found!'
esac