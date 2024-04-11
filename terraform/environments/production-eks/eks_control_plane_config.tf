# Addons
resource "aws_eks_addon" "eks_apps_vpc_cni" {
  cluster_name = aws_eks_cluster.apps.name
  addon_name   = "vpc-cni"
}

resource "aws_eks_addon" "eks_apps_kube_proxy" {
  cluster_name = aws_eks_cluster.apps.name
  addon_name   = "kube-proxy"
}

resource "aws_eks_addon" "eks_apps_coredns" {
  cluster_name = aws_eks_cluster.apps.name
  addon_name   = "coredns"
}

# OIDC config
data "tls_certificate" "apps_eks" {
  url = aws_eks_cluster.apps.identity.0.oidc.0.issuer
}

resource "aws_iam_openid_connect_provider" "apps_eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.apps_eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.apps.identity.0.oidc.0.issuer

}
