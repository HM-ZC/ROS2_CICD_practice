#include "ros2_cicd/publisher_node.hpp"

int main(int argc, char *argv[])
{
  rclcpp::init(argc, argv);
  auto node = std::make_shared<ros2_cicd_demo::PublisherNode>("demo_publisher");
  rclcpp::spin(node);
  rclcpp::shutdown();
  return 0;
}
