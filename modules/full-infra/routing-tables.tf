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