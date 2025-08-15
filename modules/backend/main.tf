data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["137112412989"]
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_security_group" "backend" {
  name   = "fleteahora-backend-sg"
  vpc_id = var.vpc_id
  tags   = merge(var.tags, { Name = "fleteahora-backend-sg" })
}

resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.backend.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "all_out" {
  security_group_id = aws_security_group.backend.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "rds_from_backend" {
  security_group_id            = var.rds_sg_id
  referenced_security_group_id = aws_security_group.backend.id
  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432
}

data "template_file" "user_data" {
  template = file("${path.module}/templates/user_data_compose.tftpl")
  vars = {
    repo_url       = var.repo_url
    app_port       = var.app_port
    db_name        = var.db_name
    db_user        = var.db_user
    db_pass        = var.db_pass
    jwt_secret     = var.jwt_secret
    cors_origin    = var.cors_origin
    enable_pgadmin = tostring(var.enable_pgadmin)
    enable_mailhog = tostring(var.enable_mailhog)
  }
}

# Asegúrate de que tu aws_instance.this apunte a este user_data:
# user_data = data.template_file.user_data.rendered


resource "aws_instance" "this" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = var.instance_type
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [aws_security_group.backend.id]
  key_name               = var.key_name

  user_data                   = data.template_file.user_data.rendered
  user_data_replace_on_change = true

  tags = merge(var.tags, { Name = "fleteahora-backend" })
}

# Detecta tu IP pública
data "http" "my_ip" {
  url = "https://checkip.amazonaws.com/"
}

locals {
  my_ip_cidr = "${chomp(data.http.my_ip.response_body)}/32"
}

# ÚNICA regla SSH (auto-IP)
resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.backend.id
  cidr_ipv4         = local.my_ip_cidr
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
}


