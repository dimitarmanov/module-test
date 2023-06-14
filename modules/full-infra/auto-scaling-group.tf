resource "aws_launch_template" "first_template" {
  name_prefix            = "terraform-"
  image_id               = data.aws_ami.latest_amazon_linux.image_id
  instance_type          = "t2.micro"
  update_default_version = true
  vpc_security_group_ids = [aws_security_group.allow_http.id]
  iam_instance_profile {
    name = aws_iam_instance_profile.ssm.name
  }
  user_data = base64encode(var.user_data_script)
}

resource "aws_autoscaling_group" "primary_asg" {
  name = "asg-nginx"
  desired_capacity    = var.desired_capacity
  max_size            = var.max_size
  min_size            = var.min_size
  vpc_zone_identifier = [aws_subnet.private_subnet1.id,aws_subnet.private_subnet2.id]
  launch_template {
    id      = aws_launch_template.first_template.id
    version = "$Latest"
  }
}

resource "aws_autoscaling_policy" "scaling-policy" {
  name                   = "scaling-policy"
  scaling_adjustment     = 4
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 30
  autoscaling_group_name = aws_autoscaling_group.primary_asg.name
}

resource "aws_autoscaling_attachment" "asg_attachment_lb" {
  autoscaling_group_name = aws_autoscaling_group.primary_asg.name
  lb_target_group_arn    = aws_lb_target_group.lb_tg.arn
}





