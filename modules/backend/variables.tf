variable "vpc_id" {
  type = string
}

variable "public_subnet_id" {
  type = string
}

variable "key_name" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "repo_url" {
  description = "URL del repo backend"
  type        = string
}

variable "app_port" {
  description = "Puerto interno de la app"
  type        = number
}

variable "jwt_secret" {
  description = "JWT secret"
  type        = string
  sensitive   = true
}

variable "cors_origin" {
  description = "CORS origin"
  default     = "*"
  type        = string
}

variable "db_host" {
  type = string
}

variable "db_user" {
  description = "Usuario BD"
  type        = string
}

variable "db_pass" {
  description = "Clave BD"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Nombre BD"
  type        = string
}

variable "rds_sg_id" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "enable_mailhog" { 
  description = "Levantar Mailhog" 
  type        = bool 
  default     = true 
}

variable "enable_pgadmin" { 
  description = "Levantar pgAdmin"
  type        = bool 
  default     = true 
}



