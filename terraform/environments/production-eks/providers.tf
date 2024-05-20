# core AWS provider.
provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Env = "prod"
    }
  }
}

# Kubernetes admin AWS provider, only use this for k8s provider.
provider "aws" {
  region = var.region
  alias  = "kubernetes_admin"

  assume_role {
    role_arn     = aws_eks_access_entry.cluster_admin.principal_arn
    session_name = "Terraform"
  }
}

data "aws_eks_cluster" "this" {
  name = aws_eks_cluster.apps.name
}

data "aws_eks_cluster_auth" "bootstrap" {
  name = data.aws_eks_cluster.this.name
}

data "aws_eks_cluster_auth" "admin" {
  provider = aws.kubernetes_admin

  name = data.aws_eks_cluster.this.name
}

locals {
  # hack to allow cluster bootstrap & destroy without circular dependency.
  k8s_token = endswith(data.aws_caller_identity.current.arn, "@deliveroo.co.uk") ? data.aws_eks_cluster_auth.bootstrap.token : data.aws_eks_cluster_auth.admin.token
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = local.k8s_token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.this.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
    token                  = local.k8s_token
  }
}

terraform {
  backend "s3" {
    bucket = "roo-platform-code-test"
    key    = "envs/production-eks/terraform.tfstate"
    region = "eu-west-1"
  }
}
