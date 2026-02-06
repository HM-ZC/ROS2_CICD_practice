cmake_minimum_required(VERSION 3.16)
project(ros2_cicd)

# 强制C++17（ROS2 Jazzy要求）
if(CMAKE_COMPILER_IS_GNUCXX OR CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  add_compile_options(-Wall -Wextra -Wpedantic)
endif()

# 查找ROS2依赖
find_package(ament_cmake REQUIRED)
find_package(rclcpp REQUIRED)
find_package(std_msgs REQUIRED)
if(BUILD_TESTING)
  find_package(ament_lint_auto REQUIRED)
  ament_lint_auto_find_test_dependencies()

  find_package(ament_cmake_gtest REQUIRED)

  ament_add_gtest(test_xxx test/test_xxx.cpp)
  target_link_libraries(test_xxx your_lib_target)
endif()

# 包含头文件目录
include_directories(include)

# 编译发布者节点可执行文件
add_executable(demo_publisher src/publisher_node.cpp)
ament_target_dependencies(demo_publisher rclcpp std_msgs)
# 安装节点到ROS2的bin目录（容器中可直接运行）
install(TARGETS
  demo_publisher
  DESTINATION lib/${PROJECT_NAME})

# 编译单元测试可执行文件
add_executable(publisher_test src/publisher_test.cpp)
ament_target_dependencies(publisher_test rclcpp std_msgs)
gtest_discover_tests(publisher_test)  # 发现GTest测试用例
# 安装测试程序（可选，CI会自动运行）
install(TARGETS
  publisher_test
  DESTINATION lib/${PROJECT_NAME})

# 安装头文件（可选）
install(DIRECTORY include/
  DESTINATION include/)

# 启用ament_lint检查（代码质量，可选）
if(BUILD_TESTING)
  find_package(ament_lint_auto REQUIRED)
  ament_lint_auto_find_test_dependencies()
endif()

# 导出包配置
ament_package()
