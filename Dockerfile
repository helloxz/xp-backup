# 基于debian:bullseye-slim构建xz-backup镜像
from debian:bullseye-slim
# 设置时区
ENV TZ=Asia/Shanghai
# 设置工作路径
WORKDIR /opt/xp-backup
# 复制当前文件夹下所有文件到到容器内
COPY . .
# 执行安装脚本
RUN bash install.sh
# 常驻运行
CMD ["bash", "run.sh"]
