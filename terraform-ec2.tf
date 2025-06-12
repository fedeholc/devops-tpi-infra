# Terraform configuration for simple EC2 deployment for Docker Compose project

provider "aws" {
  region = var.aws_region
}

resource "aws_key_pair" "deployer" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

resource "aws_security_group" "web" {
  name        = "${var.project_name}-sg"
  description = "Allow SSH, HTTP, and custom ports for Docker Compose"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 3307
    to_port     = 3307
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "aws_instance" "app" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.web.id]

  root_block_device {
    volume_size = var.volume_size
  }

  tags = {
    Name = var.project_name
  }

  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y docker.io docker-compose git
    usermod -aG docker ubuntu
    systemctl enable docker
    systemctl start docker
    # Optionally, clone your repo and run docker-compose up -d
    # git clone <your-repo-url> /home/ubuntu/app
    # cd /home/ubuntu/app
    # docker-compose up -d
  EOF
}

resource "aws_eip" "ip" {
  instance = aws_instance.app.id
  vpc      = true
}

data "aws_vpc" "default" {
  default = true
}

variable "aws_region" {
  description = "AWS region"
  default     = "us-east-2"
}

variable "key_name" {
  description = "Name for SSH key pair"
  default     = "devops-tpi-key"
}

variable "public_key_path" {
  description = "Path to your public SSH key"
  default     = "~/.ssh/id_rsa.pub"
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t3.micro"
}

variable "volume_size" {
  description = "Root volume size in GB"
  default     = 20
}

variable "project_name" {
  description = "Project name for tagging"
  default     = "devops-tpi"
}

output "public_ip" {
  value = aws_eip.ip.public_ip
}

output "ssh_command" {
  value = "ssh -i ~/.ssh/id_rsa ubuntu@${aws_eip.ip.public_ip}"
}
