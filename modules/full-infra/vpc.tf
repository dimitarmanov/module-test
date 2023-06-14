resource "aws_vpc" "main_vpc" {
  cidr_block = "172.16.0.0/16"

  tags = {
    name = "Main VPC"
  }
}
