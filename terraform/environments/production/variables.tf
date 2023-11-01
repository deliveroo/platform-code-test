data "aws_caller_identity" "current" {}

data "aws_region" "current" {}


variable "app-name" {
  type    = string
  default = "platform-code-test-app"
}

variable "app-image" {
  type    = string
  default = "920609328416.dkr.ecr.eu-west-1.amazonaws.com/platform-code-test-app:0.0.3"
}

variable "dns_public_domain" {
  type    = string
  default = "roo-coding-test.co.uk"
}

variable "region" {
  type    = string
  default = "eu-west-1"
}

variable "subnet-cidr-apps-a" {
  type    = string
  default = "10.0.0.0/19"
}

variable "subnet-cidr-dbs-a" {
  type    = string
  default = "10.0.96.0/19"
}

variable "subnet-cidr-public-a" {
  type    = string
  default = "10.0.192.0/20"
}

variable "vpc-cidr" {
  type    = string
  default = "10.0.0.0/16"
}
