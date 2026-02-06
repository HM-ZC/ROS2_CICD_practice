#include "ros2_cicd/publisher_node.hpp"

namespace ros2_cicd_demo
{
PublisherNode::PublisherNode(const std::string & node_name)
: Node(node_name), count_(0)
{
  // 创建发布者：话题/demo_topic，队列大小10
  publisher_ = this->create_publisher<std_msgs::msg::String>("/demo_topic", 10);
  // 创建定时器：1秒触发一次回调
  timer_ = this->create_wall_timer(
    std::chrono::seconds(1),
    std::bind(&PublisherNode::timer_callback, this));

  RCLCPP_INFO(this->get_logger(), "Demo Publisher Node started!");
}

void PublisherNode::timer_callback()
{
  auto msg = std_msgs::msg::String();
  msg.data = "Hello ROS2 CICD! Count: " + std::to_string(count_++);
  RCLCPP_INFO(this->get_logger(), "Publishing: '%s'", msg.data.c_str());
  publisher_->publish(msg);
}

}  // namespace ros2_cicd_demo

// 节点主函数
int main(int argc, char * argv[])
{
  rclcpp::init(argc, argv);
  rclcpp::spin(std::make_shared<ros2_cicd_demo::PublisherNode>());
  rclcpp::shutdown();
  return 0;
}
