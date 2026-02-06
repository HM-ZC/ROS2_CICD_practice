# 你的基础镜像：ROS2 Jazzy
FROM ghcr.io/hm-zc/ros2_cicd:latest

# 维护者信息（可选）
LABEL maintainer="your-name <your-email@example.com>"
LABEL description="ROS2 Jazzy CICD Demo - 基于已有依赖镜像构建"

# 关键：确认已有镜像中ROS2 Jazzy环境可正常加载
RUN /bin/bash -c "source /opt/ros/jazzy/setup.bash && echo 'ROS2 Jazzy env loaded success!'"

# ==============================================
# 核心修改：安装缺失的依赖（解决gtest_discover_tests未知问题）
# ==============================================
RUN apt update && apt install -y --no-install-recommends \
    # 系统级构建工具（基础镜像可能缺失，cmake版本需≥3.8）
    cmake \
    make \
    g++ \
    # 系统级GTest开发库（兜底，避免基础镜像无GTest）
    libgtest-dev \
    googletest \
    # 核心：ROS2 Jazzy专属的ament_cmake_gtest（提供gtest_discover_tests命令）
    ros-jazzy-ament-cmake-gtest \
    # 可选：补充colcon常用扩展，避免基础镜像缺失
    python3-colcon-common-extensions && \
    # 清理apt缓存，减少镜像体积
    rm -rf /var/lib/apt/lists/*

# 步骤1：创建ROS2工作空间并设置为工作目录
WORKDIR /colcon_ws

# 步骤2：先复制package.xml（利用Docker缓存，仅依赖变了才重新编译）
COPY src/ ./src/

# 步骤3：编译ROS2工作空间（Release模式，保留symlink-install优化）
# 必须用/bin/bash -c包裹，确保source生效
RUN /bin/bash -c "source /opt/ros/jazzy/setup.bash && \
    colcon build \
    --cmake-args -DCMAKE_BUILD_TYPE=Release \
    --symlink-install"

# 步骤4：设置环境变量——自动加载ROS2基础环境+项目工作空间环境
RUN echo "source /opt/ros/jazzy/setup.bash" >> /root/.bashrc && \
    echo "source /colcon_ws/install/setup.bash" >> /root/.bashrc

# 步骤5：容器默认命令（启动ROS2发布者节点）
CMD ["/bin/bash", "-c", "source /root/.bashrc && demo_publisher"]
