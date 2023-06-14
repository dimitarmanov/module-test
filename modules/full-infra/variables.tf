variable "image_name" {
  default     = "amzn2-ami-kernel-5.10-hvm-*-x86_64-gp2"
  type        = string
  description = "Amazon linux image name"
}

variable "user_data_script" {
  description = "User data script for EC2 instance"
  type        = string
  default = <<-EOF
    #!/bin/bash
    amazon-linux-extras install -y nginx1
    systemctl enable nginx --now
    sudo rm /usr/share/nginx/html/index.html
    echo '<html><style>body {font-size: 20px;}</style><body><p>Server 2 Ace!! &#x1F0A1;</p></body></html>' | sudo tee /usr/share/nginx/html/index.html
  EOF
}

variable "vpc_cidr" {
  type = string
  description = "Enter the VPC CIDR block"
}

variable "cidr_for_subnet_1" {
  type = string
  description = "Enter the CIDR range for Subnet 1"
}

variable "cidr_for_subnet_2" {
  type = string
  description = "Enter the CIDR range for Subnet 1"
}

variable "cidr_for_subnet_3" {
  type = string
  description = "Enter the CIDR range for Subnet 1"
}

variable "cidr_for_subnet_4" {
  type = string
  description = "Enter the CIDR range for Subnet 1"
}

variable "desired_capacity" {
  type = number
}

variable "min_size" {
  type = number
}

variable "max_size" {
  type = number
}