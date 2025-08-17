variable "create_rds" {
  type    = bool
  default = true
}

variable "vpc_id" {
  type = string
}

variable "private_subnets" {
  type = list(string)
}

variable "db_name" {
  type = string
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

variable "tags" {
  type    = map(string)
  default = {}
}

variable "enabled" {
  description = "Si false, no se crea RDS"
  type        = bool
  default     = false
}

variable "repo_ref" {
  description = "Ref del repo (commit/branch/tag)"
  type        = string
  default     = "main"
}

variable "db_mode" {
  type        = string
  description = "compose | rds"
  default     = "compose"
  validation {
    condition     = contains(["compose","rds"], var.db_mode)
    error_message = "db_mode debe ser 'compose' o 'rds'."
  }
}
