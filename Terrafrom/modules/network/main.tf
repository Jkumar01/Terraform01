locals {
  name_prefix = "${var.project_name}-${var.environment}"

  base_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    },
    var.common_tags
  )

  nat_gateway_count = (
    var.nat_gateway_mode == "per_az" ? 2 :
    var.nat_gateway_mode == "single" ? 1 :
    0
  )
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.base_tags, {
    Name = "${local.name_prefix}-vpc"
  })
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.base_tags, {
    Name = "${local.name_prefix}-igw"
  })
}

resource "aws_subnet" "public" {
  count = 2

  vpc_id                  = aws_vpc.main.id
  availability_zone       = var.availability_zones[count.index]
  cidr_block              = var.public_subnet_cidrs[count.index]
  map_public_ip_on_launch = true

  tags = merge(local.base_tags, {
    Name = "${local.name_prefix}-public-${count.index + 1}"
    Tier = "Public"
    AZ   = var.availability_zones[count.index]
  })
}

resource "aws_subnet" "private" {
  count = 2

  vpc_id                  = aws_vpc.main.id
  availability_zone       = var.availability_zones[count.index]
  cidr_block              = var.private_subnet_cidrs[count.index]
  map_public_ip_on_launch = false

  tags = merge(local.base_tags, {
    Name = "${local.name_prefix}-private-${count.index + 1}"
    Tier = "PrivateCompute"
    AZ   = var.availability_zones[count.index]
  })
}

resource "aws_subnet" "database" {
  count = 2

  vpc_id                  = aws_vpc.main.id
  availability_zone       = var.availability_zones[count.index]
  cidr_block              = var.database_subnet_cidrs[count.index]
  map_public_ip_on_launch = false

  tags = merge(local.base_tags, {
    Name = "${local.name_prefix}-database-${count.index + 1}"
    Tier = "IsolatedDatabase"
    AZ   = var.availability_zones[count.index]
  })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.base_tags, {
    Name = "${local.name_prefix}-public-rt"
    Tier = "Public"
  })
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public" {
  count = 2

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "nat" {
  count = local.nat_gateway_count

  domain = "vpc"

  tags = merge(local.base_tags, {
    Name = "${local.name_prefix}-nat-eip-${count.index + 1}"
  })

  depends_on = [aws_internet_gateway.main]
}

resource "aws_nat_gateway" "main" {
  count = local.nat_gateway_count

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(local.base_tags, {
    Name = "${local.name_prefix}-nat-${count.index + 1}"
  })

  depends_on = [aws_internet_gateway.main]
}

resource "aws_route_table" "private" {
  count = 2

  vpc_id = aws_vpc.main.id

  tags = merge(local.base_tags, {
    Name = "${local.name_prefix}-private-rt-${count.index + 1}"
    Tier = "PrivateCompute"
  })
}

resource "aws_route" "private_nat_per_az" {
  count = var.nat_gateway_mode == "per_az" ? 2 : 0

  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main[count.index].id
}

resource "aws_route" "private_nat_single" {
  count = var.nat_gateway_mode == "single" ? 2 : 0

  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main[0].id
}

resource "aws_route_table_association" "private" {
  count = 2

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

resource "aws_route_table" "database" {
  count = 2

  vpc_id = aws_vpc.main.id

  tags = merge(local.base_tags, {
    Name = "${local.name_prefix}-database-rt-${count.index + 1}"
    Tier = "IsolatedDatabase"
  })
}

resource "aws_route_table_association" "database" {
  count = 2

  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database[count.index].id
}

resource "aws_db_subnet_group" "database" {
  name        = "${local.name_prefix}-db-subnet-group"
  description = "Isolated database subnets for ${local.name_prefix}"
  subnet_ids  = aws_subnet.database[*].id

  tags = merge(local.base_tags, {
    Name = "${local.name_prefix}-db-subnet-group"
  })
}