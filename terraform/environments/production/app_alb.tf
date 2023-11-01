resource "aws_security_group" "test_app_alb_public" {
  name        = "${var.app-name}-alb"
  description = "Allow traffic for ${var.app-name} alb-public"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.app-name}-alb"
  }
}


resource "aws_lb" "test_app_public" {
  name               = "${var.app-name}-public"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.test_app_alb_public.id]
  subnets            = [aws_subnet.subnet_public_a.id]

  tags = {
    Name = "${var.app-name}-public"
  }
}

resource "aws_lb_target_group" "test_app_public" {
  name        = "${var.app-name}-public"
  port        = 8080
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.app-name}-public"
  }
}

resource "aws_lb_listener" "test_app_public" {
  load_balancer_arn = aws_lb.test_app_public.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.test_app_public.arn
  }

  tags = {
    Name = "${var.app-name}-public"
  }
}
