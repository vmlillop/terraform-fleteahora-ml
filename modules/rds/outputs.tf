############################
# modules/rds/outputs.tf
############################

output "endpoint" {
  value       = var.enabled ? aws_db_instance.this[0].address : null
  description = "Endpoint (hostname) de la instancia RDS, o null si RDS deshabilitado."
}

output "port" {
  value       = var.enabled ? aws_db_instance.this[0].port : 5432
  description = "Puerto del servicio RDS (5432 por defecto)."
}

output "sg_id" {
  value       = var.enabled ? aws_security_group.rds[0].id : null
  description = "ID del Security Group asociado a RDS, o null si RDS deshabilitado."
}
