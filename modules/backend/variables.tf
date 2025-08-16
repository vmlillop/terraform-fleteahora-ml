############################
# modules/backend/variables.tf
# Variables del módulo BACKEND (EC2 + app)
############################

# --- Red / EC2 ---
variable "vpc_id" {
  description = "VPC donde se desplegará la instancia EC2 del backend"
  type        = string
}

variable "public_subnet_id" {
  description = "Subnet pública donde se colocará la EC2 del backend"
  type        = string
}

variable "instance_type" {
  description = "Tipo de instancia para el backend"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Nombre del key pair para la EC2"
  type        = string
}

# --- Código / App ---
variable "repo_url" {
  description = "URL del repositorio Git del backend"
  type        = string
}

variable "app_port" {
  description = "Puerto interno en el que escucha la app Node"
  type        = number
  default     = 8080
}

variable "cors_origin" {
  description = "Origen permitido para CORS"
  type        = string
  default     = "*"
}

variable "jwt_secret" {
  description = "Secreto para firmar JWT"
  type        = string
  sensitive   = true
}

# --- Base de datos (modo y credenciales) ---
variable "db_mode" {
  description = "Modo de base de datos: compose (Postgres en Docker) o rds (RDS gestionado)"
  type        = string
  default     = "compose"
  validation {
    condition     = contains(["compose", "rds"], var.db_mode)
    error_message = "db_mode debe ser 'compose' o 'rds'."
  }
}

variable "db_host" {
  description = "Endpoint RDS cuando db_mode = 'rds' (ej: fleteahora-db.xxxxxx.rds.amazonaws.com)"
  type        = string
  default     = ""
}

variable "db_name" {
  description = "Nombre de la base de datos"
  type        = string
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

# --- Servicios de demo ---
variable "enable_pgadmin" {
  description = "Habilitar contenedor pgAdmin (solo tiene efecto en db_mode = 'compose')"
  type        = bool
  default     = true
}

variable "enable_mailhog" {
  description = "Habilitar contenedor Mailhog"
  type        = bool
  default     = true
}

# --- Integración opcional con SG de RDS ---
variable "rds_sg_id" {
  description = "Security Group de RDS para crear regla de acceso desde el backend (opcional)"
  type        = string
  default     = null
}

# --- Etiquetas ---
variable "tags" {
  description = "Tags a aplicar a los recursos del backend"
  type        = map(string)
  default     = {}
}


variable "repo_ref" {
  description = "Rama, tag o commit del backend a desplegar (ej: main, v1.2.3, 0a1b2c3)"
  type        = string
  default     = "main"
}
