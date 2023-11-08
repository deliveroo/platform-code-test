resource "aws_route53_zone" "main_public" {
  name = var.dns_public_domain

  tags = {
    Name = "main"
  }
}

resource "aws_route53domains_registered_domain" "main_public" {
  domain_name = var.dns_public_domain

  dynamic "name_server" {
    for_each = aws_route53_zone.main_public.name_servers
    content {
      name = name_server.value
    }
  }
}
