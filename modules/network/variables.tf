variable "create_network" {
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

variable "tags" {
  type    = map(string)
  default = {}
}
