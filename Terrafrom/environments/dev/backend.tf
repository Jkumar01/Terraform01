terraform {
  backend "s3" {
    bucket         = "cde-terraform-state-dev"
    key            = "dev/network/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}