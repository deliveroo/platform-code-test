data "aws_caller_identity" "current" {}

data "aws_iam_policy" "candidate_permissions_boundary" {
  name = var.permissions_boundary_name
}


variable "app_name" {
  type    = string
  default = "platform-code-test-app"
}

variable "dns_public_domain" {
  type    = string
  default = "roo-sandbox-plat-coding-test.co.uk"
}

variable "permissions_boundary_name" {
  description = "Perms boundary policy name for IAM users"
  default     = "prod-plat-recruitment-candidate-permissions-boundary"
  type        = string
}

variable "region" {
  type    = string
  default = "eu-west-1"
}
