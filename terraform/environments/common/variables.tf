data "aws_caller_identity" "current" {}

variable "app_name" {
  type    = string
  default = "platform-code-test-app"
}

variable "dns_public_domain" {
  type    = string
  default = "roo-plat-coding-test.co.uk"
}

variable "region" {
  type    = string
  default = "eu-west-1"
}
