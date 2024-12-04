# Basic role allowing access to Kubernetes API.
resource "aws_iam_role" "kubernetes_cluster_admin" {
  name = "kubernetes-cluster-admin"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow"
        "Principal" : {
          "AWS" : data.aws_caller_identity.current.account_id
        }
        "Action" : "sts:AssumeRole"
      }
    ]
  })
  permissions_boundary = data.aws_iam_policy.candidate_permissions_boundary.arn
}

resource "aws_iam_policy" "kubernetes_cluster_admin" {
  name = aws_iam_role.kubernetes_cluster_admin.name
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "eks:DescribeCluster",
          "eks:AccessKubernetesApi",
        ]
        "Resource" : "*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "kubernetes_cluster_admin" {
  role       = aws_iam_role.kubernetes_cluster_admin.name
  policy_arn = aws_iam_policy.kubernetes_cluster_admin.arn
}
