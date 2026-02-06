#ifndef ROS2_CICD_DEMO_PUBLISHER_NODE_HPP
#define ROS2_CICD_DEMO_PUBLISHER_NODE_HPP

#include "rclcpp/rclcpp.hpp"
#include "std_msgs/msg/string.hpp"

namespace ros2_cicd_demo
{
class PublisherNode : public rclcpp::Node
{
public:
  // 构造函数
  explicit PublisherNode(const std::string & node_name = "demo_publisher");

private:
  // 定时器回调：发布话题
  void timer_callback();

  // 定时器对象
  rclcpp::TimerBase::SharedPtr timer_;
  // 发布者对象
  rclcpp::Publisher<std_msgs::msg::String>::SharedPtr publisher_;
  // 计数变量（测试用）
  size_t count_;
};

}  // namespace ros2_cicd_demo

#endif  // ROS2_CICD_DEMO_PUBLISHER_NODE_HPP
