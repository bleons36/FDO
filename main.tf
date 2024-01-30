provider "aws" {
  region = "ap-northeast-2"
}

locals {
  tfe_dev_instance_tags = {
    Name = "tfe_dev_instance"
  }
}

resource "aws_vpc" "tfe_dev_instance" {
  cidr_block = "172.16.0.0/16"

  tags = local.tfe_dev_instance_tags
}

resource "aws_subnet" "tfe_dev_instance" {
  vpc_id            = aws_vpc.tfe_dev_instance.id
  cidr_block        = "172.16.10.0/24"
  availability_zone = "ap-northeast-2a"

  tags = local.tfe_dev_instance_tags
}

resource "aws_security_group" "tfe_dev_instance" {
  name   = "tfe_dev_instance"
  vpc_id = aws_vpc.tfe_dev_instance.id

  dynamic "ingress" {
    for_each = toset([22, 443])
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = local.tfe_dev_instance_tags
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "tfe_dev_instance" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.large"
  subnet_id     = aws_subnet.tfe_dev_instance.id
  key_name      = "hw-key"

  security_groups = [aws_security_group.tfe_dev_instance.id]

  root_block_device {
    volume_size = 50
    volume_type = "gp2"
  }

  tags = local.tfe_dev_instance_tags

  user_data_replace_on_change = true
  user_data                   = <<-EOT
    #! /bin/bash
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    sudo usermod -aG docker ubuntu
    sudo systemctl enable docker --now
  EOT
}

resource "aws_eip" "tfe_dev_instance" {
  instance   = aws_instance.tfe_dev_instance.id
  domain     = "vpc"
  depends_on = [aws_internet_gateway.tfe_dev_instance]
}

resource "aws_internet_gateway" "tfe_dev_instance" {
  vpc_id = aws_vpc.tfe_dev_instance.id
}

resource "aws_route_table" "tfe_dev_instance" {
  vpc_id = aws_vpc.tfe_dev_instance.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tfe_dev_instance.id
  }
}

resource "aws_route_table_association" "tfe_dev_instance" {
  subnet_id      = aws_subnet.tfe_dev_instance.id
  route_table_id = aws_route_table.tfe_dev_instance.id
}