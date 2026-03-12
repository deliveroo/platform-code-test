terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.36.0"
      configuration_aliases = [
        aws,
        aws.kubernetes_admin,
      ]
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.38.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.17.0"
    }
  }
  required_version = "~> 1.5"
}
