output "public_ip" {
  value = module.backend.public_ip
}

output "ssh_command" {
  value = "ssh -i <path-to-key.pem> ec2-user@${module.backend.public_ip}"
}

output "db_endpoint" {
  value = module.rds.endpoint
}


output "db_mode" {
  value       = module.backend.effective_db_mode
  description = "compose o rds"
}

output "db_host" {
  value       = module.backend.effective_db_host
  description = "Host destino de la BD"
}
