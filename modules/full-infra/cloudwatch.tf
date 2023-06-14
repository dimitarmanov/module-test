resource "aws_cloudwatch_metric_alarm" "cpu_alarm" {
  alarm_name          = "cpu-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 50
  alarm_description   = "This metric monitors ec2 cpu utilization"
  treat_missing_data  = "breaching"
  alarm_actions       = [aws_autoscaling_policy.scaling-policy.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.primary_asg.name
  }
}