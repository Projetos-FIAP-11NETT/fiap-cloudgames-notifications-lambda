terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  # LocalStack endpoint configuration
  endpoints {
    iam    = var.localstack_endpoint
    lambda = var.localstack_endpoint
    sqs    = var.localstack_endpoint
    ses    = var.localstack_endpoint
  }

  # LocalStack credentials (dummy values)
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key

  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_region_validation      = true
}
