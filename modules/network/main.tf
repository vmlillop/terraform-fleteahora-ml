locals {
  create = var.create_network && var.vpc_id == null
}

data "aws_availability_zones" "available" {}

resource "aws_vpc" "this" {
  count                = local.create ? 1 : 0
  cidr_block           = "10.20.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = merge(var.tags, { Name = "fleteahora-vpc" })
}

resource "aws_internet_gateway" "igw" {
  count  = local.create ? 1 : 0
  vpc_id = aws_vpc.this[0].id
  tags   = merge(var.tags, { Name = "fleteahora-igw" })
}

resource "aws_subnet" "public" {
  count                   = local.create ? 2 : 0
  vpc_id                  = aws_vpc.this[0].id
  cidr_block              = cidrsubnet("10.20.0.0/16", 4, count.index)
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  tags                    = merge(var.tags, { Name = "fleteahora-public-${count.index}" })
}

resource "aws_subnet" "private" {
  count                   = local.create ? 2 : 0
  vpc_id                  = aws_vpc.this[0].id
  cidr_block              = cidrsubnet("10.20.0.0/16", 4, count.index + 8)
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  tags                    = merge(var.tags, { Name = "fleteahora-private-${count.index}" })
}

resource "aws_route_table" "public" {
  count  = local.create ? 1 : 0
  vpc_id = aws_vpc.this[0].id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw[0].id
  }
  tags = merge(var.tags, { Name = "fleteahora-rt-public" })
}

resource "aws_route_table_association" "public" {
  count          = local.create ? length(aws_subnet.public) : 0
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[0].id
}

locals {
  vpc_id_out          = local.create ? aws_vpc.this[0].id : var.vpc_id
  public_subnets_out  = local.create ? aws_subnet.public[*].id : var.public_subnets
  private_subnets_out = local.create ? aws_subnet.private[*].id : var.private_subnets
}
