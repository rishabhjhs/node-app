variable "region" {
  type = string
  description = "region"
}

variable "vpc_cidr_block" {
  type        = string
  description = "CIDR block for VPC"
}

variable "public_subnet_cidr_blocks" {
  type        = list(string)
  description = "CIDR block for public subnet"
}

variable "env" {
  type = string
  description = "environment where it will be created"
}

variable "release_version" {
  type = string
  description = "Image version which needs to be deployed"
  default = ""
}