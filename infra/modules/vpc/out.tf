output "subnet_ids" {
  value = aws_subnet.app_subnet[*].id
}

output "vpc_id" {
  value = aws_vpc.app_vpc.id
}
