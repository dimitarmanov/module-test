resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main_vpc.id

    tags = {
    Name = "Main-igw"
  }
}