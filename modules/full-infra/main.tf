## Data ##

## Getting latest Amazon Linux image ##
data "aws_ami" "latest_amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = [var.image_name]
  }
}

## IAM ##

## Creating assume policy ##
data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy" "ssm_managed" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"

}

## VPC ##

resource "aws_vpc" "main_vpc" {
  cidr_block = "172.16.0.0/16"

  tags = {
    name = "Main VPC"
  }
}


## IGW ##

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main_vpc.id

    tags = {
    Name = "Main-igw"
  }
}

## NAT ##

resource "aws_nat_gateway" "subnet1_nat_gw" {
  connectivity_type = "public"
  subnet_id = aws_subnet.public_subnet1.id
  allocation_id = aws_eip.subnet1-nat.id

  tags = {
    Name = "NAT-gw-subnet1"
  }
}

resource "aws_nat_gateway" "subnet2_nat_gw" {
  connectivity_type = "public"
  subnet_id = aws_subnet.public_subnet2.id
  allocation_id = aws_eip.subnet2-nat.id

    tags = {
    Name = "NAT-gw-subnet2"
  }
}

resource "aws_eip" "subnet1-nat" {
  domain = "vpc"
}

resource "aws_eip" "subnet2-nat" {
  domain = "vpc"
}

## Subnets ##

resource "aws_subnet" "public_subnet1" {
  vpc_id = aws_vpc.main_vpc.id
  cidr_block = "172.16.1.0/24"
  availability_zone = "eu-west-1a"

  tags = {
    Name = "Public-subnet-1"
  }
}


resource "aws_subnet" "public_subnet2" {
  vpc_id = aws_vpc.main_vpc.id
  cidr_block = "172.16.3.0/24"
  availability_zone = "eu-west-1b"

  tags = {
    Name = "Public-subnet-2"
  }
}


resource "aws_subnet" "private_subnet1" {
  vpc_id = aws_vpc.main_vpc.id
  cidr_block = "172.16.4.0/24"
  availability_zone = "eu-west-1a"

  tags = {
    Name = "Private-subnet-1"
  }
}

resource "aws_subnet" "private_subnet2" {
  vpc_id = aws_vpc.main_vpc.id
  cidr_block = "172.16.5.0/24"
  availability_zone = "eu-west-1b"

  tags = {
    Name = "Private-subnet-2"
  }

}

## Routing Tables ##

resource "aws_route_table" "public_rt1" {
  vpc_id = aws_vpc.main_vpc.id

    route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
    tags = {
    Name = "public-rt1"
  }
}

resource "aws_route_table" "public_rt2" {
  vpc_id = aws_vpc.main_vpc.id

    route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
    tags = {
    Name = "public-rt2"
  }
}

resource "aws_route_table" "private_rt1" {
  vpc_id = aws_vpc.main_vpc.id

    route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.subnet1_nat_gw.id
  }
    tags = {
    Name = "private-rt1"
  }
}

resource "aws_route_table" "private_rt2" {
  vpc_id = aws_vpc.main_vpc.id

    route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.subnet2_nat_gw.id
  }
    tags = {
    Name = "private-rt2"
  }
}

resource "aws_route_table_association" "public_rt1" {
  subnet_id      = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.public_rt1.id
}

resource "aws_route_table_association" "public_rt2" {
  subnet_id      = aws_subnet.public_subnet2.id
  route_table_id = aws_route_table.public_rt2.id
}

resource "aws_route_table_association" "private_rt1" {
  subnet_id      = aws_subnet.private_subnet1.id
  route_table_id = aws_route_table.private_rt1.id
}

resource "aws_route_table_association" "private_rt2" {
  subnet_id      = aws_subnet.private_subnet2.id
  route_table_id = aws_route_table.private_rt2.id
}

## Security Groups ##

resource "aws_security_group" "allow_http" {
  name   = "http-allow-sg"
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main_vpc.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "alb_sg" {
  name   = "alb-sg"
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["91.211.97.132/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

## Application Load Balancer ##

resource "aws_lb" "alb" {
  name               = "terraform-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_subnet1.id, aws_subnet.public_subnet2.id]

  enable_deletion_protection = false
}

resource "aws_lb_target_group" "lb_tg" {
  name     = "terraform-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main_vpc.id
}

resource "aws_lb_listener" "nginx_lbl" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_tg.arn
  }
}


## For Auto scaling group ##

resource "aws_iam_role" "ssm_mgmt" {
  name = "ssm-mgmt"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

resource "aws_iam_role_policy_attachment" "ssm_mgmt_attachment" {
  role       = aws_iam_role.ssm_mgmt.id
  policy_arn = data.aws_iam_policy.ssm_managed.arn
}

resource "aws_iam_instance_profile" "ssm" {
  name = "instance-profile"
  role = aws_iam_role.ssm_mgmt.name
}



## Auto Scaling group ##

resource "aws_launch_template" "first_template" {
  name_prefix            = "terraform-"
  image_id               = data.aws_ami.latest_amazon_linux.image_id
  instance_type          = "t2.micro"
  update_default_version = true
  vpc_security_group_ids = [aws_security_group.allow_http.id]
  iam_instance_profile {
    name = aws_iam_instance_profile.ssm.name
  }
  user_data = base64encode(
    <<-EOF
    #!/bin/bash
    amazon-linux-extras install -y nginx1
    systemctl enable nginx --now
    sudo rm /usr/share/nginx/html/index.html
    echo '<html><style>body {font-size: 20px;}</style><body><p>Server 2 Ace!! &#x1F0A1;</p></body></html>' | sudo tee /usr/share/nginx/html/index.html
    EOF
  )
}

resource "aws_autoscaling_group" "primary_asg" {
  name = "asg-nginx"
  desired_capacity    = 2
  max_size            = 4
  min_size            = 2
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


## CloudWatch ##

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