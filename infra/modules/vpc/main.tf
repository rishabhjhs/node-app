resource "aws_vpc" "app_vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "app-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.app_vpc.id

  tags = {
    "Name" = "igw"
  }
}

resource "aws_route_table" "app_route_table" {
  vpc_id = aws_vpc.app_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    "Name" = "app-route-table"
  }
}

resource "aws_route_table_association" "public_crt_public_subnet" {
  count = length(var.public_subnet_cidr_blocks)
  subnet_id      = aws_subnet.app_subnet[count.index].id
  route_table_id = aws_route_table.app_route_table.id
}