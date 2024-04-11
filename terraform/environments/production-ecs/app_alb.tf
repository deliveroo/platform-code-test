resource "aws_security_group" "test_app_alb_public" {
  name        = "${var.app_name}-alb"
  description = "Allow traffic for ${var.app_name} alb-public"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.app_name}-alb"
  }
}


resource "aws_lb" "test_app_public" {
  name               = "${var.app_name}-public"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.test_app_alb_public.id]
  subnets            = [aws_subnet.subnet_public_a.id, aws_subnet.subnet_public_b.id, aws_subnet.subnet_public_c.id]

  tags = {
    Name = "${var.app_name}-public"
  }
}

resource "aws_lb_target_group" "test_app_public" {
  name     = "${var.app_name}-public"
  port     = 8080
  protocol = "HTTP"
  tags = {
    Name = "${var.app_name}-public"
  }
  target_type = "ip"
  vpc_id      = aws_vpc.main.id

  health_check {
    healthy_threshold   = 2
    interval            = 5
    path                = "/healthcheck"
    timeout             = 3
    unhealthy_threshold = 3
  }
}

resource "aws_lb_listener" "test_app_public" {
  certificate_arn   = aws_acm_certificate.main_public.arn
  load_balancer_arn = aws_lb.test_app_public.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  tags = {
    Name = "${var.app_name}-public"
  }

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.test_app_public.arn
  }
}
