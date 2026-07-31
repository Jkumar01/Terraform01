output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "Public subnet IDs for ALB and NAT Gateways"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "Private compute subnet IDs"
  value       = aws_subnet.private[*].id
}

output "database_subnet_ids" {
  description = "Isolated database subnet IDs"
  value       = aws_subnet.database[*].id
}

output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = aws_internet_gateway.main.id
}

output "nat_gateway_ids" {
  description = "NAT Gateway IDs"
  value       = aws_nat_gateway.main[*].id
}

output "public_route_table_id" {
  description = "Public route table ID"
  value       = aws_route_table.public.id
}

output "private_route_table_ids" {
  description = "Private compute route table IDs"
  value       = aws_route_table.private[*].id
}

output "database_route_table_ids" {
  description = "Isolated database route table IDs"
  value       = aws_route_table.database[*].id
}

output "database_subnet_group_name" {
  description = "RDS DB subnet group name"
  value       = aws_db_subnet_group.database.name
}