variable "region" {
  type    = string
  default = "us-east-1"
}

variable "create_network" {
  type    = bool
  default = true
}

variable "create_rds" {
  type    = bool
  default = true
}

variable "vpc_id" {
  type    = string
  default = null
}

variable "public_subnets" {
  type    = list(string)
  default = null
}

variable "private_subnets" {
  type    = list(string)
  default = null
}

variable "db_name" {
  type    = string
  default = "fleteahora"
}

variable "db_username" {
  type      = string
  sensitive = true
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "db_instance_class" {
  type    = string
  default = "db.t4g.micro"
}

variable "key_name" {
  type = string
}

variable "repo_url" {
  type = string
}

variable "app_port" {
  type    = number
  default = 8080
}

variable "jwt_secret" {
  type      = string
  sensitive = true
}

variable "cors_origin" {
  type    = string
  default = "*"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}
