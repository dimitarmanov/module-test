resource "aws_subnet" "public_subnet1" {
  vpc_id = aws_vpc.main_vpc.id
  cidr_block = var.cidr_for_subnet_1
  availability_zone = "eu-west-1a"

  tags = {
    Name = "Public-subnet-1"
  }
}


resource "aws_subnet" "public_subnet2" {
  vpc_id = aws_vpc.main_vpc.id
  cidr_block = var.cidr_for_subnet_2
  availability_zone = "eu-west-1b"

  tags = {
    Name = "Public-subnet-2"
  }
}


resource "aws_subnet" "private_subnet1" {
  vpc_id = aws_vpc.main_vpc.id
  cidr_block = var.cidr_for_subnet_3
  availability_zone = "eu-west-1a"

  tags = {
    Name = "Private-subnet-1"
  }
}

resource "aws_subnet" "private_subnet2" {
  vpc_id = aws_vpc.main_vpc.id
  cidr_block = var.cidr_for_subnet_4
  availability_zone = "eu-west-1b"

  tags = {
    Name = "Private-subnet-2"
  }

}