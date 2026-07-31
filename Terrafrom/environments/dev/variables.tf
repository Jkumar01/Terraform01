variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "cde-modernization"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
}

variable "availability_zones" {
  description = "Two Availability Zones"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "Private compute subnet CIDRs"
  type        = list(string)
}

variable "database_subnet_cidrs" {
  description = "Isolated database subnet CIDRs"
  type        = list(string)
}

variable "nat_gateway_mode" {
  description = "NAT mode: per_az, single, or none"
  type        = string
  default     = "per_az"
}