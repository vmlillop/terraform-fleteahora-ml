############################
# Variables raíz (root)
############################

# Región y red
variable "region" {
  description = "Región de AWS"
  type        = string
  default     = "us-east-1"
}

variable "create_network" {
  description = "Crear la VPC/Subnets desde este stack"
  type        = bool
  default     = true
}

variable "vpc_id" {
  description = "VPC existente (si no se crea)"
  type        = string
  default     = null
}

variable "public_subnets" {
  description = "IDs de subnets públicas (si no se crean)"
  type        = list(string)
  default     = null
}

variable "private_subnets" {
  description = "IDs de subnets privadas (si no se crean)"
  type        = list(string)
  default     = null
}

# Modo de base de datos
variable "use_rds" {
  description = "true = RDS + EC2; false = EC2 con Docker Compose (DB local)"
  type        = bool
  default     = false
}

# Credenciales y parámetros de DB (nombres consistentes)
variable "db_name" {
  description = "Nombre de la base de datos"
  type        = string
  default     = "fleteahora"
}

variable "db_user" {
  description = "Usuario de la base de datos"
  type        = string
}

variable "db_pass" {
  description = "Password del usuario de la base de datos"
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "Clase de instancia para RDS (solo si use_rds=true)"
  type        = string
  default     = "db.t4g.micro"
}

# Parámetros de la app/backend
variable "key_name" {
  description = "Nombre del key pair para la EC2"
  type        = string
}

variable "repo_url" {
  description = "URL del repositorio Git del backend"
  type        = string
}

variable "app_port" {
  description = "Puerto interno de la app Node"
  type        = number
  default     = 8080
}

variable "jwt_secret" {
  description = "Secreto para JWT"
  type        = string
  sensitive   = true
}

variable "cors_origin" {
  description = "Origen permitido para CORS"
  type        = string
  default     = "*"
}

variable "instance_type" {
  description = "Tipo de instancia EC2 para el backend"
  type        = string
  default     = "t3.micro"
}

# Utilidades para modo demo/tesis
variable "enable_pgadmin" {
  description = "Habilitar contenedor pgAdmin (solo en modo Compose)"
  type        = bool
  default     = true
}

variable "enable_mailhog" {
  description = "Habilitar contenedor Mailhog"
  type        = bool
  default     = true
}
