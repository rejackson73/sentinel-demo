terraform {
  backend "remote" {
    organization = "rjackson-demo"
    workspaces {
      name = "sentinel-demo"
    }
  }
}

provider "aws" {
  region                  = "us-west-2"
  profile                 = "default"
  shared_credentials_file = "~/.aws/credentials"
}


data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource aws_vpc "rj-demo" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    name = "${var.prefix}-vpc"
  }
}

resource aws_subnet "rj-demo" {
  vpc_id     = aws_vpc.nomad-demo.id
  cidr_block = var.vpc_cidr
  tags = {
    name = "${var.prefix}-subnet"
  }
}

resource aws_security_group "rj-demo" {
  name = "${var.prefix}-security-group"

  vpc_id = aws_vpc.rj-demo.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    prefix_list_ids = []
  }

  tags = {
    Name = "${var.prefix}-security-group"
  }
}

resource "aws_instance" "compute" {
  ami           = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  key_name                    = var.aws_key
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.rj-demo.id
  vpc_security_group_ids      = [aws_security_group.rj-demo.id]
  tags = {
    Owner = "rjackson"
    TTL = 1
  }
}
