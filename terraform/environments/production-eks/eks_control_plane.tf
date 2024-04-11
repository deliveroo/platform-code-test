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
      aws_subnet.subnet_public_a.id,
      aws_subnet.subnet_public_b.id,
      aws_subnet.subnet_public_c.id,
    ]
    public_access_cidrs     = ["0.0.0.0/0"]
    endpoint_public_access  = true
    endpoint_private_access = true
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
  name               = "eks-apps-control-plane"
  assume_role_policy = data.aws_iam_policy_document.eks_assume_role.json
}

resource "aws_iam_role_policy_attachment" "eks_apps_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_apps.name
}

resource "aws_iam_role_policy_attachment" "eks_apps_vpc_resource" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_apps.name
}
