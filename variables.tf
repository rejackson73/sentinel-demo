variable "region" {
  default = "us-east-1"
}

variable "prefix" {
  default = "robj"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR of the VPC"
  default     = "192.168.100.0/24"
}

variable "instance_type" {
  type        = string
  description = "machine instance type"
  default     = "t3.micro"
}

variable "aws_key" {
  type        = string
  description = "aws security PEM key"
}

variable "ssh_key" {
  type        = string
  description = "private key"
}
