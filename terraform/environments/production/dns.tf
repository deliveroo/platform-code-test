resource "aws_route53_zone" "main_public" {
  name = "roo-coding-test.co.uk"

  tags = {
    Environment = "prd"
  }
}
