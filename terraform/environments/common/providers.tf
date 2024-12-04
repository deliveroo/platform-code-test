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
    bucket = "roo-sandbox-platform-code-test-state"
    key    = "envs/common/terraform.tfstate"
    region = "eu-west-1"
  }
}
