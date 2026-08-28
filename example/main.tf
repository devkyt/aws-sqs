locals {
  app    = "whatever"
  env    = "experiment"
  region = "eu-central-1"

  tags = {
    Name        = local.app
    Environment = local.env
    Region      = local.region
  }
}

terraform {
  backend "s3" {
    bucket = "terraform-experiments-state"
    region = "eu-central-1"
    key    = "whatever/terraform.tfstate"
  }
}


provider "aws" {
  region = local.region
}


module "sqs" {
  source = "git@github.com:devkyt/aws-sqs.git?ref=main&depth=1"

  app = local.app
  env = local.env

  visibility_timeout_seconds = 60
  max_retry_count            = 3

  tags = local.tags
}
