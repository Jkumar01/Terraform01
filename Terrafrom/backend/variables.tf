variable "aws_region" {
  default = "ap-south-1"
}

variable "state_bucket_name" {
  default = "cde-terraform-state-dev"
}

variable "lock_table_name" {
  default = "terraform-locks"
}