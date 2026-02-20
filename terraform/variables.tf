data "aws_caller_identity" "current" {}

data "aws_ecr_image" "app_image" {
  repository_name = var.app_name
  image_tag       = "latest"
}


data "aws_iam_policy" "candidate_permissions_boundary" {
  name = var.permissions_boundary_name
}

data "aws_region" "current" {}

data "aws_route53_zone" "main_public" {
  name         = var.dns_public_domain
  private_zone = false
  tags = {
    Env  = "prod"
    Name = "main"
  }
}


variable "app_rds_master_username" {
  type    = string
  default = "root"
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

variable "subnet_cidr_apps_a" {
  type    = string
  default = "10.0.0.0/19"
}

variable "subnet_cidr_apps_b" {
  type    = string
  default = "10.0.32.0/19"
}

variable "subnet_cidr_dbs_a" {
  type    = string
  default = "10.0.96.0/19"
}

variable "subnet_cidr_dbs_b" {
  type    = string
  default = "10.0.128.0/19"
}

variable "subnet_cidr_dbs_c" {
  type    = string
  default = "10.0.160.0/19"
}

variable "subnet_cidr_public_a" {
  type    = string
  default = "10.0.192.0/20"
}

variable "subnet_cidr_public_b" {
  type    = string
  default = "10.0.208.0/20"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}
