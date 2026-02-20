# EKS control plane
resource "aws_eks_cluster" "apps" {
  depends_on = [
    aws_iam_role_policy_attachment.eks_apps_cluster_policy,
    aws_iam_role_policy_attachment.eks_apps_vpc_resource,
  ]
  name     = "apps"
  role_arn = aws_iam_role.eks_apps.arn

  vpc_config {
    subnet_ids = [
      aws_subnet.subnet_apps_a.id,
      aws_subnet.subnet_apps_b.id,
    ]
    public_access_cidrs     = ["0.0.0.0/0"]
    endpoint_public_access  = true
    endpoint_private_access = true
  }

  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }
}

# Allow Kubernetes admin IAM role access to EKS API
resource "aws_eks_access_entry" "cluster_admin" {
  cluster_name      = aws_eks_cluster.apps.name
  principal_arn     = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/kubernetes-cluster-admin"
  kubernetes_groups = ["cluster-superadmin"]
  type              = "STANDARD"
}

resource "kubernetes_cluster_role_binding" "cluster_admin" {
  metadata {
    name = "aws-cluster-admin"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  dynamic "subject" {
    for_each = aws_eks_access_entry.cluster_admin.kubernetes_groups

    content {
      kind      = "Group"
      name      = subject.key
      api_group = "rbac.authorization.k8s.io"
    }
  }
}


# EKS control plane IAM
data "aws_iam_policy_document" "eks_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "eks_apps" {
  name                 = "eks-apps-control-plane"
  assume_role_policy   = data.aws_iam_policy_document.eks_assume_role.json
  permissions_boundary = data.aws_iam_policy.candidate_permissions_boundary.arn
}

resource "aws_iam_role_policy_attachment" "eks_apps_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_apps.name
}

resource "aws_iam_role_policy_attachment" "eks_apps_vpc_resource" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_apps.name
}
