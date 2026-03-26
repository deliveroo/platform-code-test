resource "helm_release" "app" {
  depends_on = [
    aws_eks_fargate_profile.apps_default,
  ]

  name  = var.app_name
  chart = "${path.module}/../charts/platform-code-test-app"

  set {
    name  = "nameOverride"
    value = var.app_name
  }

  set {
    name  = "image.repository"
    value = data.aws_ecr_image.app_image.image_uri
  }
}
