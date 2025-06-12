# Variables de configuración

variable "aws_region" {
  description = "Región de AWS donde se desplegará la infraestructura"
  type        = string
  default     = "us-east-2"
}

variable "environment" {
  description = "Ambiente de despliegue (dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "instance_type" {
  description = "Tipo de instancia EC2"
  type        = string
  default     = "t3.micro"
}

variable "volume_size" {
  description = "Tamaño del volumen EBS en GB"
  type        = number
  default     = 20
}

variable "public_key_path" {
  description = "Ruta al archivo de clave pública SSH"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
  default     = "devops-tpi"
}
