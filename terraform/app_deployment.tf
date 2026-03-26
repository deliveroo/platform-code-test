resource "helm_release" "app" {
  depends_on = [
    aws_eks_fargate_profile.apps_default,
    helm_release.aws_load_balancer_controller,
  ]

  name  = var.app_name
  chart = "${path.module}/../charts/platform-code-test-app"

  values = [
    yamlencode({
      name = var.app_name
      image = {
        repository = data.aws_ecr_image.app_image.image_uri
      }
      ingress = {
        subnets         = join(",", [aws_subnet.subnet_public_a.id, aws_subnet.subnet_public_b.id])
        certificateArn  = aws_acm_certificate.main_public.arn
        securityGroupId = aws_security_group.test_app_alb_public.id
      }
    })
  ]
}
