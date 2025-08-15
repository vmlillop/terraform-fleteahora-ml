############################
# modules/backend/outputs.tf
############################

output "public_ip" {
  description = "IP pública de la instancia backend"
  value       = aws_instance.this.public_ip
}

output "public_dns" {
  description = "DNS público de la instancia backend"
  value       = aws_instance.this.public_dns
}

output "instance_id" {
  description = "ID de la instancia EC2 del backend"
  value       = aws_instance.this.id
}

output "ssh_command" {
  description = "Comando de conexión SSH (reemplaza <path-to-key.pem> por tu ruta real)"
  value       = "ssh -i <path-to-key.pem> ec2-user@${aws_instance.this.public_ip}"
}

output "health_url" {
  description = "Endpoint de healthcheck servido por Nginx en la instancia"
  value       = "http://${aws_instance.this.public_ip}/healthz"
}

output "sg_id" {
  description = "Security Group de la instancia backend"
  value       = aws_security_group.backend.id
}
