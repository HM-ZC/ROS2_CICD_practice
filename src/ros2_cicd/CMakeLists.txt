cmake_minimum_required(VERSION 3.16)
project(ros2_cicd)

# 强制C++17（ROS2 Jazzy要求）
if(CMAKE_COMPILER_IS_GNUCXX OR CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  add_compile_options(-Wall -Wextra -Wpedantic)
endif()

# 查找ROS2基础依赖
find_package(ament_cmake REQUIRED)
find_package(rclcpp REQUIRED)
find_package(std_msgs REQUIRED)
# 查找ROS2 GTest封装（辅助）
find_package(ament_cmake_gtest REQUIRED)
# 查找原生GTest CMake模块（核心，提供gtest_discover_tests命令）
find_package(GTest REQUIRED)

# 包含头文件目录
include_directories(include)

### 库相关新增1：编译核心业务库（将PublisherNode的实现编译成库）
# 库名：ros2_cicd_core，源文件：publisher_node.cpp（业务实现）
add_library(ros2_cicd_core src/publisher_node.cpp)
# 库链接ROS2依赖（rclcpp/std_msgs）
ament_target_dependencies(ros2_cicd_core rclcpp std_msgs)
# 安装库文件（ROS2规范，必须安装，否则其他可执行文件链接不到）
install(TARGETS ros2_cicd_core
  EXPORT export_${PROJECT_NAME}
  ARCHIVE DESTINATION lib
  LIBRARY DESTINATION lib
  RUNTIME DESTINATION bin)

# 编译发布者节点可执行文件
add_executable(demo_publisher src/publisher_node_main.cpp)  ### 库相关修改：建议拆分主函数（可选，见下方说明）
### 库相关新增2：节点可执行文件链接业务库（核心，让demo_publisher能调用PublisherNode）
target_link_libraries(demo_publisher ros2_cicd_core)
ament_target_dependencies(demo_publisher rclcpp std_msgs)
# 安装节点到ROS2的bin目录
install(TARGETS
  demo_publisher
  DESTINATION lib/${PROJECT_NAME})

# 安装头文件（ROS2规范，必须安装）
install(DIRECTORY include/
  DESTINATION include/)

# 启用ament_lint检查+编译单元测试（统一放到BUILD_TESTING块，规范）
if(BUILD_TESTING)
  # 代码质量检查
  find_package(ament_lint_auto REQUIRED)
  ament_lint_auto_find_test_dependencies()

  # 编译单元测试可执行文件
  add_executable(publisher_test src/publisher_test.cpp)
  # 链接ROS2依赖
  ament_target_dependencies(publisher_test rclcpp std_msgs)
  # 链接GTest库
  target_link_libraries(publisher_test GTest::gtest GTest::gtest_main)
  ### 库相关新增3：测试程序链接业务库（核心，解决本次未定义引用错误）
  target_link_libraries(publisher_test ros2_cicd_core)
  # 发现GTest测试用例
  gtest_discover_tests(publisher_test)
  # 安装测试程序（可选，CI运行用）
  install(TARGETS
    publisher_test
    DESTINATION lib/${PROJECT_NAME})
endif()

# 导出包配置（ROS2规范，配合库的安装）
ament_export_targets(export_${PROJECT_NAME} HAS_LIBRARY_TARGET)
ament_export_dependencies(rclcpp std_msgs)
ament_package()
