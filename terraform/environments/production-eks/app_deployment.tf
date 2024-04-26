resource "kubernetes_deployment" "app" {
  depends_on = [
    aws_eks_fargate_profile.apps_default,
  ]

  metadata {
    name = var.app_name
  }

  spec {
    selector {
      match_labels = {
        app = var.app_name
      }
    }

    template {
      metadata {
        labels = {
          app = var.app_name
        }
      }

      spec {
        container {
          image = var.app_image
          name  = "app"

          env {
            name  = "DB_HOST"
            value = aws_rds_cluster.test_app.endpoint
          }

          env {
            name = "DB_USER"
            value_from {
              secret_key_ref {
                name     = "db-credentials"
                key      = "db_user"
                optional = false
              }
            }
          }

          env {
            name = "DB_PASSWORD"
            value_from {
              secret_key_ref {
                name     = "db-credentials"
                key      = "db_password"
                optional = false
              }
            }
          }

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "512Mi"
            }
          }
        }
      }
    }
  }
}
