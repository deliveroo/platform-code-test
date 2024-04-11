resource "aws_eks_node_group" "apps_core" {
  cluster_name    = aws_eks_cluster.apps.name
  node_group_name = "core"
  node_role_arn   = aws_iam_role.eks_apps_node.arn
  subnet_ids = [
    aws_subnet.subnet_apps_a.id,
  ]

  scaling_config {
    desired_size = 1
    max_size     = 5
    min_size     = 1
  }

  launch_template {
    id      = aws_launch_template.eks_node.id
    version = aws_launch_template.eks_node.latest_version
  }

  update_config {
    max_unavailable = 5
  }

  force_update_version = true

  depends_on = [
    aws_iam_role_policy_attachment.eks_apps_worker_node_policy,
    aws_iam_role_policy_attachment.eks_apps_cni_node_policy,
    aws_iam_role_policy_attachment.eks_apps_node_ecr,
  ]

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }
}

resource "aws_launch_template" "eks_node" {
  name_prefix            = "apps-eks"
  update_default_version = true

  vpc_security_group_ids = [
    aws_eks_cluster.apps.vpc_config[0].cluster_security_group_id,
    aws_security_group.eks_node.id,
  ]
}

resource "aws_security_group" "eks_node" {
  name   = "apps-eks-node"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.2.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_iam_policy_document" "eks_node_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "eks_apps_node" {
  name               = "eks-apps-node"
  assume_role_policy = data.aws_iam_policy_document.eks_node_assume_role.json
}

resource "aws_iam_role_policy_attachment" "eks_apps_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_apps_node.name
}

resource "aws_iam_role_policy_attachment" "eks_apps_cni_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_apps_node.name
}

resource "aws_iam_role_policy_attachment" "eks_apps_node_ecr" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_apps_node.name
}

