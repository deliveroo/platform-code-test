resource "aws_route53_record" "test_app_public" {
  name    = "${var.app_name}.${var.dns_public_domain}"
  type    = "A"
  zone_id = data.aws_route53_zone.main_public.zone_id

  alias {
    evaluate_target_health = true
    name                   = aws_lb.test_app_public.dns_name
    zone_id                = aws_lb.test_app_public.zone_id
  }
}
