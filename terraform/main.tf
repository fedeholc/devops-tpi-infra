# Configuración del provider de AWS
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configuración del provider AWS
provider "aws" {
  region = var.aws_region
}

# Data source para obtener la AMI más reciente de Ubuntu
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Data source para obtener la VPC por defecto
data "aws_vpc" "default" {
  default = true
}

# Security Group para la instancia EC2
resource "aws_security_group" "devops_tpi_sg" {
  name        = "devops-tpi-security-group"
  description = "Security group for DevOps TPI application"
  vpc_id      = data.aws_vpc.default.id

  # HTTP (puerto 80)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP"
  }

  # SSH (puerto 22)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH"
  }

  # Puerto para desarrollo (opcional)
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Frontend Development"
  }

  # Puerto backend para desarrollo (opcional)
  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Backend Development"
  }

  # Puerto MySQL (opcional, para acceso externo)
  ingress {
    from_port   = 3307
    to_port     = 3307
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "MySQL"
  }

  # Todas las salidas permitidas
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = {
    Name        = "devops-tpi-sg"
    Project     = "DevOps TPI"
    Environment = var.environment
  }
}

# Key Pair para acceso SSH
resource "aws_key_pair" "devops_tpi_key" {
  key_name   = "devops-tpi-key"
  public_key = file(var.public_key_path)

  tags = {
    Name        = "devops-tpi-key"
    Project     = "DevOps TPI"
    Environment = var.environment
  }
}

# Instancia EC2
resource "aws_instance" "devops_tpi_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name              = aws_key_pair.devops_tpi_key.key_name
  vpc_security_group_ids = [aws_security_group.devops_tpi_sg.id]

  # Script de inicialización para instalar Docker y Docker Compose
  user_data = templatefile("${path.module}/user_data.sh", {
    docker_compose_content = base64encode(file("${path.module}/../docker-compose.yml"))
    nginx_conf_content     = base64encode(file("${path.module}/../nginx.conf"))
    db_init_content        = base64encode(file("${path.module}/../sql/db-init.sql"))
    db_schema_content      = base64encode(file("${path.module}/../sql/db-schema.sql"))
    db_seeds_content       = base64encode(file("${path.module}/../sql/db-seeds.sql"))
  })

  # Configurar el volumen root
  root_block_device {
    volume_type = "gp3"
    volume_size = var.volume_size
    encrypted   = true

    tags = {
      Name        = "devops-tpi-root-volume"
      Project     = "DevOps TPI"
      Environment = var.environment
    }
  }

  tags = {
    Name        = "devops-tpi-server"
    Project     = "DevOps TPI"
    Environment = var.environment
  }
}

# Elastic IP para la instancia
resource "aws_eip" "devops_tpi_eip" {
  instance = aws_instance.devops_tpi_server.id
  domain   = "vpc"

  tags = {
    Name        = "devops-tpi-eip"
    Project     = "DevOps TPI"
    Environment = var.environment
  }

  depends_on = [aws_instance.devops_tpi_server]
}
