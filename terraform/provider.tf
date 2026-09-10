terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Local state used deliberately here (single-operator portfolio project).
  # In a team setting this would be an S3 backend + DynamoDB lock table:
  # backend "s3" {
  #   bucket         = "your-tfstate-bucket"
  #   key            = "tf-ansible-webapp/terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "terraform-locks"
  #   encrypt        = true
  # }
}

provider "aws" {
  region = var.aws_region
}