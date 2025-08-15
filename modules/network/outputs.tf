output "vpc_id" {
  value = local.vpc_id_out
}

output "public_subnet_ids" {
  value = local.public_subnets_out
}

output "private_subnet_ids" {
  value = local.private_subnets_out
}
