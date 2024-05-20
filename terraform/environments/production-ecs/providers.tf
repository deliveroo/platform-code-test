provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Env = "prod"
    }
  }
}

terraform {
  backend "s3" {
    bucket = "roo-platform-code-test"
    key    = "envs/production/terraform.tfstate"
    region = "eu-west-1"
  }
}
