output "public_ip" {
  value = module.backend.public_ip
}

output "ssh_command" {
  value = "ssh -i <path-to-key.pem> ec2-user@${module.backend.public_ip}"
}

output "db_endpoint" {
  value = module.rds.endpoint
}
