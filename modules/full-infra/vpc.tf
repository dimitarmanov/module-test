resource "aws_vpc" "main_vpc" {
  cidr_block = var.vpc_cidrblock

  tags = {
    name = "Main VPC"
  }
}
