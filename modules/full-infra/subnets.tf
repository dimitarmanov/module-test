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