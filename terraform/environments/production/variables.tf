variable "app-name" {
  type    = string
  default = "platform-code-test-app"
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
