# Outputs útiles

output "instance_id" {
  description = "ID de la instancia EC2"
  value       = aws_instance.devops_tpi_server.id
}

output "instance_public_ip" {
  description = "IP pública de la instancia EC2"
  value       = aws_eip.devops_tpi_eip.public_ip
}

output "instance_public_dns" {
  description = "DNS público de la instancia EC2"
  value       = aws_instance.devops_tpi_server.public_dns
}

output "ssh_connection_command" {
  description = "Comando para conectarse por SSH a la instancia"
  value       = "ssh -i ~/.ssh/id_rsa ubuntu@${aws_eip.devops_tpi_eip.public_ip}"
}

output "application_url" {
  description = "URL de la aplicación"
  value       = "http://${aws_eip.devops_tpi_eip.public_ip}"
}

output "security_group_id" {
  description = "ID del Security Group"
  value       = aws_security_group.devops_tpi_sg.id
}
