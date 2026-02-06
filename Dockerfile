# 核心修改：FROM你的已有依赖镜像（替换为实际镜像地址+标签，如私有仓库/公共仓库）
# 示例1：公共仓库镜像 → FROM your-registry/ros2_humble_base:latest
# 示例2：GHCR私有镜像 → FROM ghcr.io/your-name/ros2_humble_deps:v1.0
# 示例3：本地镜像（仅本地测试，CI需推送到仓库）→ FROM ros2_humble_base:local
FROM ghcr.io/hm-zc/ros2_cicd:latest

# 维护者信息（可选）
LABEL maintainer="your-name <your-email@example.com>"
LABEL description="ROS2 Humble CICD Demo - 基于已有依赖镜像构建"

# 关键：确认已有镜像中ROS2环境可正常加载（做一次验证，避免环境问题）
RUN /bin/bash -c "source /opt/ros/jazzy/setup.bash && echo 'ROS2 Jazzy env loaded success!'"

# 步骤1：创建ROS2工作空间并设置为工作目录（和之前一致，保持路径统一）
WORKDIR /colcon_ws

# 步骤2：先复制package.xml（利用Docker缓存！仅依赖描述文件变了才重新编译）
# 已有镜像已装所有依赖，此步骤仅为缓存优化，避免源码变动导致重新编译
COPY src/ ./src/

# 步骤3：编译ROS2工作空间（Release模式，保留symlink-install优化）
# 必须用/bin/bash -c包裹，确保source生效（已有镜像的ROS2环境）
RUN /bin/bash -c "source /opt/ros/jazzy/setup.bash && \
    colcon build \
    --cmake-args -DCMAKE_BUILD_TYPE=Release \
    --symlink-install"

# 步骤4：设置环境变量——容器启动自动加载ROS2基础环境+项目工作空间环境
# 已有镜像可能未配置自动加载，此处补充，保证容器运行时无需手动source
RUN echo "source /opt/ros/jazzy/setup.bash" >> /root/.bashrc && \
    echo "source /colcon_ws/install/setup.bash" >> /root/.bashrc

# 步骤5：容器默认命令（启动ROS2发布者节点，和之前一致，保证功能正常）
CMD ["/bin/bash", "-c", "source /root/.bashrc && demo_publisher"]
