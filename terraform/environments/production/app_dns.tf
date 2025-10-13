resource "aws_route53_record" "test_app_public" {
  name    = "${var.app_name}.${var.dns_public_domain}"
  type    = "CNAME"
  zone_id = data.aws_route53_zone.main_public.zone_id
  ttl     = 60

  records = [
    kubernetes_ingress_v1.test_app_public.status.0.load_balancer.0.ingress.0.hostname
  ]
}
