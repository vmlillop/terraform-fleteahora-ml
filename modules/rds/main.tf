resource "aws_db_subnet_group" "this" {
  count      = var.create_rds ? 1 : 0
  name       = "fleteahora-db-subnet-group"
  subnet_ids = var.private_subnets
  tags       = merge(var.tags, { Name = "fleteahora-db-subnet-group" })
}

resource "aws_security_group" "rds" {
  count  = var.create_rds ? 1 : 0
  name   = "fleteahora-rds-sg"
  vpc_id = var.vpc_id
  tags   = merge(var.tags, { Name = "fleteahora-rds-sg" })
}

resource "aws_vpc_security_group_egress_rule" "rds_egress_all" {
  count             = var.create_rds ? 1 : 0
  security_group_id = aws_security_group.rds[0].id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_db_instance" "this" {
  count                   = var.create_rds ? 1 : 0
  identifier              = "fleteahora-db"
  engine                  = "postgres"
  engine_version          = "16"
  instance_class          = var.db_instance_class
  allocated_storage       = 20
  db_name                 = var.db_name
  username                = var.db_username
  password                = var.db_password
  db_subnet_group_name    = aws_db_subnet_group.this[0].name
  vpc_security_group_ids  = [aws_security_group.rds[0].id]
  publicly_accessible     = false
  skip_final_snapshot     = true
  deletion_protection     = false
  storage_encrypted       = true
  backup_retention_period = 1
  apply_immediately       = true
  tags                    = merge(var.tags, { Name = "fleteahora-db" })
}
