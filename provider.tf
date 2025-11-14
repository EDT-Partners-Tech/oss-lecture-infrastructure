# © [2025] EDT&Partners. Licensed under CC BY 4.0.

variable "available_buckets" {
  default = {
    prod = "lecture-prod-terraform-state-prod"
  }
}

terraform {
  required_version = ">= 1.0.0"
  backend "s3" {
    key    = "lecture-terraform/terraform.tfstate"
    region = "us-east-1"
  }
}
provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      environment = var.environment
      owner       = "${var.project}-terraform"
      project     = var.project
    }
  }

}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 5.98.0"
    }
    awscc = {
      source  = "hashicorp/awscc"
      version = "1.45.0"
    }

  }
}

# Provider for us-east-1 (global resources)
provider "aws" {
  alias  = "virginia"
  region = "us-east-1"
}



provider "awscc" {
  region = var.aws_region
}