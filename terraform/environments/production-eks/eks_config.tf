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
  depends_on = [
    aws_eks_fargate_profile.apps_default,
  ]

  cluster_name = aws_eks_cluster.apps.name
  addon_name   = "coredns"
  configuration_values = jsonencode({
    computeType = "Fargate"
  })
}

# load balancer controller
resource "helm_release" "aws_load_balancer_controller" {
  depends_on = [
    aws_iam_role_policy_attachment.eks_load_balancer,
    aws_eks_fargate_profile.apps_default,
  ]

  name       = "aws-load-balancer-controller"
  namespace  = "kube-system"
  chart      = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"

  set {
    name  = "clusterName"
    value = aws_eks_cluster.apps.name
  }
  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.eks_load_balancer.arn
  }
  set {
    name  = "region"
    value = data.aws_region.current.name
  }
  set {
    name  = "vpcId"
    value = aws_vpc.main.id
  }
}

data "aws_iam_policy_document" "eks_load_balancer_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.apps_eks.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.apps_eks.arn, "/^(.*provider/)/", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.apps_eks.arn, "/^(.*provider/)/", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_load_balancer" {
  name               = "eks-apps-load-balancer"
  assume_role_policy = data.aws_iam_policy_document.eks_load_balancer_assume_role.json
}

resource "aws_iam_policy" "eks_load_balancer" {
  name   = "eks-apps-load-balancer"
  policy = file("${path.module}/files/aws-load-balancer-controller-policy.json")
}

resource "aws_iam_role_policy_attachment" "eks_load_balancer" {
  role       = aws_iam_role.eks_load_balancer.name
  policy_arn = aws_iam_policy.eks_load_balancer.arn
}

# metrics server
resource "helm_release" "metrics_server" {
  depends_on = [
    aws_eks_fargate_profile.apps_default,
  ]

  name       = "metrics-server"
  namespace  = "kube-system"
  chart      = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server"

  set {
    name  = "containerPort"
    value = "4443"
  }
  set {
    name  = "args.0"
    value = "--kubelet-insecure-tls"
  }
  set {
    name  = "args.1"
    value = "--kubelet-preferred-address-types=ExternalIP\\,Hostname\\,InternalIP"
  }
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
