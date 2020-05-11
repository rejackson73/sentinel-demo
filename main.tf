provider "aws" {
  region                  = var.region
  profile                 = "default"
  shared_credentials_file = "~/.aws/credentials"
}


# data "aws_ami" "ubuntu" {
#   most_recent = true

#   filter {
#     name   = "name"
#     values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
#   }

#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }

#   owners = ["099720109477"] # Canonical
# }

data aws_ami "rj-demo" {
  most_recent = true

  filter {
    name = "name"
    #values = ["ubuntu/images/hvm-ssd/ubuntu-disco-19.04-amd64-server-*"]
    #values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
    values = ["robj-demo*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name = "root-device-type"
    values = ["ebs"]
  }

  owners = ["self"] # Canonical
}

resource aws_vpc "rj-demo" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    name = "${var.prefix}-vpc"
  }
}

resource aws_subnet "rj-demo" {
  vpc_id     = aws_vpc.rj-demo.id
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

resource aws_internet_gateway "rj-demo" {
  vpc_id = aws_vpc.rj-demo.id

  tags = {
    Name = "${var.prefix}-internet-gateway"
  }
}

resource aws_route_table "rj-demo" {
  vpc_id = aws_vpc.rj-demo.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.rj-demo.id
  }
}

resource aws_route_table_association "rj-demo" {
  subnet_id      = aws_subnet.rj-demo.id
  route_table_id = aws_route_table.rj-demo.id
}

resource "aws_instance" "compute" {
  ami                         = data.aws_ami.rj-demo.id
  instance_type               = var.instance_type
  key_name                    = var.ssh_key
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.rj-demo.id
  vpc_security_group_ids      = [aws_security_group.rj-demo.id]
  user_data                   = templatefile("ssh-helper-template.tpl",{vault_address = var.vault_address})
  tags = {
    Owner = "rjackson"
  }
}
