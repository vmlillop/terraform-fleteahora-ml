############################
# modules/backend/main.tf
############################

# AMI Amazon Linux 2023 (x86_64)
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["137112412989"] # Amazon

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

# Security Group del backend
resource "aws_security_group" "backend" {
  name   = "fleteahora-backend-sg"
  vpc_id = var.vpc_id
  tags   = merge(var.tags, { Name = "fleteahora-backend-sg" })
}

# HTTP 80 abierto (para Nginx)
resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.backend.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
}

# Egress libre
resource "aws_vpc_security_group_egress_rule" "all_out" {
  security_group_id = aws_security_group.backend.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

# Si usas RDS, crea (opcionalmente) una regla en el SG de RDS para permitir
# conexiones desde el SG del backend (solo cuando db_mode = "rds" y rds_sg_id no es null)
resource "aws_vpc_security_group_ingress_rule" "rds_from_backend" {
  count                        = var.db_mode == "rds" && var.rds_sg_id != null ? 1 : 0
  security_group_id            = var.rds_sg_id
  referenced_security_group_id = aws_security_group.backend.id
  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432
  description                  = "Allow Postgres from backend SG"
}

# Detecta tu IP pública (para restringir SSH)
data "http" "my_ip" {
  url = "https://checkip.amazonaws.com/"
}

locals {
  my_ip_cidr = "${chomp(data.http.my_ip.response_body)}/32"
}

# SSH solo desde tu IP actual
resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.backend.id
  cidr_ipv4         = local.my_ip_cidr
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  description       = "SSH from ${local.my_ip_cidr}"
}

# ---- user_data renderizado con templatefile() ----
# Pasa TODO lo que necesita el script (incluye flags en string: "true"/"false")
locals {
  user_data = templatefile("${path.module}/templates/user_data_compose.tftpl", {
    repo_url       = var.repo_url
    app_port       = var.app_port
    db_name        = var.db_name
    db_user        = var.db_user
    db_pass        = var.db_pass
    jwt_secret     = var.jwt_secret
    cors_origin    = var.cors_origin
    enable_pgadmin = tostring(var.enable_pgadmin)
    enable_mailhog = tostring(var.enable_mailhog)

    # Modo BD (compose | rds) y host RDS (si aplica)
    db_mode = var.db_mode
    db_host = var.db_host
  })
}

# Instancia EC2 que aloja Nginx + App (y Compose en modo "compose")
resource "aws_instance" "this" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = var.instance_type
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [aws_security_group.backend.id]
  key_name               = var.key_name

  # user_data desde tu template (local.user_data ya debería renderizarlo)
  user_data                   = local.user_data
  user_data_replace_on_change = true

  # ⬇⬇⬇ AUMENTA el disco raíz a 30 GiB (puedes poner 30 si quieres más holgura)
  root_block_device {
    volume_size           = 30
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = merge(var.tags, { Name = "fleteahora-backend" })
}
