output "public_ip" {
  value = aws_instance.this.public_ip
}

output "sg_id" {
  value = aws_security_group.backend.id
}
