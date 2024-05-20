resource "aws_eks_fargate_profile" "apps_default" {
  cluster_name           = aws_eks_cluster.apps.name
  fargate_profile_name   = "default"
  pod_execution_role_arn = aws_iam_role.fargate_execution_role.arn
  subnet_ids = [
    aws_subnet.subnet_apps_a.id,
    aws_subnet.subnet_apps_b.id,
  ]

  selector {
    namespace = "*"
  }
}

data "aws_iam_policy_document" "fargate_execution_role_assume_role_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks-fargate-pods.amazonaws.com"]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values = [
        "arn:aws:eks:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:fargateprofile/${aws_eks_cluster.apps.name}/default/*"
      ]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "fargate_execution_role" {
  name               = "eks-fargate-${aws_eks_cluster.apps.name}-default"
  assume_role_policy = data.aws_iam_policy_document.fargate_execution_role_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "eks_apps_cni_fargate_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.fargate_execution_role.name
}

resource "aws_iam_role_policy_attachment" "eks_apps_fargate_ecr" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.fargate_execution_role.name
}

