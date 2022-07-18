resource "aws_subnet" "app_subnet" {
  count = length(var.public_subnet_cidr_blocks)
  vpc_id = aws_vpc.app_vpc.id
  cidr_block = var.public_subnet_cidr_blocks[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name  = "public_subnet_${count.index}"
  }
}