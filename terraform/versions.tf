terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.44.0"
      configuration_aliases = [
        aws,
        aws.kubernetes_admin,
      ]
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "3.2.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.2.0"
    }
  }
  required_version = "~> 1.5"
}
