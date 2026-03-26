resource "aws_security_group" "test_app_alb_public" {
  name        = "${var.app_name}-alb"
  description = "Allow traffic for ${var.app_name} alb-public"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["10.2.0.0/16"]
  }

  tags = {
    Name = "${var.app_name}-alb"
  }
}

resource "aws_security_group_rule" "test_app_alb_pod_ingress" {
  security_group_id = aws_eks_cluster.apps.vpc_config.0.cluster_security_group_id

  type        = "ingress"
  from_port   = 8080
  to_port     = 8080
  protocol    = "-1"
  cidr_blocks = ["10.0.0.0/16"]
}
