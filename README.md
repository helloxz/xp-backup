# xp-backup

基于Docker容器的备份方案，使用restic工具定期将您的MySQL数据库和文件加密备份到AWS S3。

### 特性

* 加密备份
* 增量备份
* 自动备份MySQL数据库
* 支持添加多个备份路径
* 支持备份到S3或SFTP
* 支持路径排除
* 支持快捷命令查看备份列表（快照）
* 支持快捷命令自动恢复指定备份（快照）


## 安装使用

在使用之前，请确保您熟悉Linux并掌握了Docker容器使用，此工具推荐给运维人员使用，小白请勿尝试！！！

1) 已经安装Docker环境，并安装了Docker Compose工具
2) 创建`docker-compose.yaml`文件，内容为：

```yaml
version: '3'
services:
 xp-backup:
   image: helloz/xp-backup
   container_name: xp-backup
   restart: always
   environment:
      - PATH=/opt/xp-backup:$PATH
   volumes:
     - ./data:/opt/xp-backup/data
     - /data/apps:/opt/xp-backup/backup/apps
     - /data/backup/mysql:/opt/xp-backup/backup/mysql
     # 如果使用SFTP备份方式，还需要挂载私钥文件
     # - ./data/id_rsa:/root/.ssh/id_rsa
     # - ~/.ssh/known_hosts:/root/.ssh/known_hosts:ro
   network_mode: "host"
```

如果您有更多需要备份的目录，可以继续添加挂载，需要挂载到容器内部的`/opt/xp-backup/backup`目录下，比如：

* `/test1/dir:/opt/xp-backup/backup/test1`
* `/test2/dir:/opt/xp-backup/backup/test2`

输入命令`docker-compose up -d`启动容器，启动完毕后回在您本地挂载目录`./data`下生成2个隐藏文件，分别是：

* `.env`:环境变量文件
* `.restic_pass`: restic密码文件（加密备份和解密需要）

您可以输入命令`ls -al`来查看这2个文件，首次运行后自动生成这2个文件，然后删除容器：`docker-compose down`，并对这2个文件做出修改，修改完毕后再次启动容器：`docker-compose up -d`

**`.env`环境变量说明：**

```bash
# 备份目标类型，支持s3、sftp，默认s3
STORAGE_TYPE="s3"
# MySQL连接地址
DB_HOST=127.0.0.1
# MySQL用户名
DB_USER=root
# MySQL密码
DB_PASSWORD=xxx
#需要排除的数据库，用|分割
DB_EXCLUDE="test|mysql|information_schema|sys"

# AWS_ACCESS_KEY_ID
AWS_ACCESS_KEY_ID=xxx
# AWS_SECRET_ACCESS_KEY
AWS_SECRET_ACCESS_KEY=xxx
# AWS_S3_URL，格式如：s3.us-west-002.backblazeb2.com
AWS_S3_URL=s3.us-west-002.backblazeb2.com
# AWS_BUCKET_NAME，存储桶名称
AWS_BUCKET_NAME="bucket_name"

#restic密码，用于加密备份和解密恢复，一旦设置不要修改
RESTIC_PASSWORD="xp_backup_password"

#需要排除的目录，多个目录使用空格分割，比如：--exclude=dir1 --exclude=dir2
EXCLUDE_DIRS='--exclude=default'

# 定时备份MySQL的时间，默认每天凌晨2点
CRON_TIME_MYSQL="0 2 * * *"
# 定时备份文件夹的时间，默认每天凌晨3点
CRON_TIME_DIR="0 3 * * *"
# SFTP用户名
SFTP_USER="sftp_user"
# SFTP主机
SFTP_HOST="sftp_host"
# SFTP端口
SFTP_PORT=22
```

**.restic_pass 密码文件** 

需要自行设置一个复制的字符串，默认为：`xp_backup_password`，一旦设置后，请不要随意修改。

`.env`和`.restic_pass`设置完毕后，输入命令：`docker-compose restart`重启一次容器，至此已经全部设置完毕，容器将根据您的定时任务定期将MySQL数据库和文件数据加密备份至AWS S3

**补充**

如果您选择使用SFTP作为备份方式，需要进行以下操作：

1. 修改`.env`为`STORAGE_TYPE="sftp"`
2. 设置SFTP相关参数，包括`STORAGE_TYPE`/`SFTP_HOST`/`SFTP_PORT`
3. 容器启动之前先执行`ssh -i /path/to/your_private_key <user>@<host> -p <port>`
   1. `/path/to/your_private_key`私钥文件路径
   2. `<user>`服务器用户名
   3. `<host>`服务器IP
   4. `<port>`服务器端口
  
> 注意：如果不提前执行SSH命令登录，可能会出现交互式询问，`restic`无法绕过将导致备份失败！

### 常用命令

* 立即备份MySQL：`docker exec -it xp-backup backup_mysql.sh`
* 立即备份文件数据：`docker exec -it xp-backup restic_backup.sh`
* 查看备份列表：`docker exec -it xp-backup tool.sh list`
* 清理并保留最近60个快照：`docker exec -it xp-backup tool.sh clear`
* 将指定快照恢复到指定目录下：`docker exec -it xp-backup tool.sh restore snapshot_id target_path`
  * `snapshot_id`：快照ID
  * `target_path`：目标路径（将数据恢复到这个路径）

### 技术支持

如果遇到BUG或者新功能请求，请在[issues](https://github.com/helloxz/xp-backup/issues)进行反馈，如果需要人工技术支持（需要付费），通过下面方式联系我。

* 微信：`xiaozme`
* Telegram：`xiaozme`