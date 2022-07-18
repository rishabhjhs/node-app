variable "vpc_cidr_block" {
  type = string
  description = "cidr block to create vpc with"
}

variable "public_subnet_cidr_blocks" {
  type = list
  description = "subnet cidr block"
}