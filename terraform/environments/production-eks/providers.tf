provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Env = "prod"
    }
  }
}

data "aws_eks_cluster" "this" {
  name = aws_eks_cluster.apps.name
}

data "aws_eks_cluster_auth" "this" {
  name = data.aws_eks_cluster.this.name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.this.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}


terraform {
  backend "s3" {
    bucket = "roo-platform-code-test"
    key    = "envs/production/terraform.tfstate"
    region = "eu-west-1"
  }
}