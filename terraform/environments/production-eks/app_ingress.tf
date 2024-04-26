resource "kubernetes_service" "app_node_port" {
  metadata {
    name = var.app_name
  }
  spec {
    selector = {
      app = var.app_name
    }
    port {
      port = 8080
    }
    type = "NodePort"
  }
}

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
    cidr_blocks = ["10.0.0.0/16"]
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

resource "kubernetes_ingress_v1" "test_app_public" {
  depends_on = [
    helm_release.aws_load_balancer_controller,
  ]

  metadata {
    name = var.app_name
    annotations = {
      "kubernetes.io/ingress.class"                = "alb"
      "alb.ingress.kubernetes.io/certificate-arn"  = aws_acm_certificate.main_public.arn
      "alb.ingress.kubernetes.io/security-groups"  = aws_security_group.test_app_alb_public.id
      "alb.ingress.kubernetes.io/scheme"           = "internet-facing"
      "alb.ingress.kubernetes.io/target-type"      = "ip"
      "alb.ingress.kubernetes.io/healthcheck-path" = "/healthcheck"
    }
  }

  spec {
    rule {
      http {
        path {
          backend {
            service {
              name = kubernetes_service.app_node_port.metadata.0.name
              port {
                number = 8080
              }
            }
          }
          path = "/*"
        }
      }
    }
  }

  wait_for_load_balancer = true
}
