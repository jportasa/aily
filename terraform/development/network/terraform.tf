terraform {
  required_version = "1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.20"
    }
  }

  backend "s3" {
    bucket               = "aily-terraform-state"
    workspace_key_prefix = "terraform"
    key                  = "development/network"
    region               = "us-east-1"
    dynamodb_table       = "terraform_locks"
    role_arn             = "arn:aws:iam::953835556803:role/joan-prova-eks"
  }
}

provider "aws" {
  region = "us-east-1"

  allowed_account_ids = ["953835556803"]
  assume_role {
    role_arn = "arn:aws:iam::953835556803:role/joan-prova-eks"
  }

  default_tags {
    tags = {
      Owner       = "aily"
      Terraform   = "https://github.com/aily/infra/tree/main/terraform/development/network"
      Application = "eks"
      Project     = "infra"
    }
  }
}
