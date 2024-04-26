resource "kubernetes_secret" "db_credentials" {
  metadata {
    name      = "db-credentials"
    namespace = "default"
  }
  data = {
    db_user     = var.app_rds_master_username
    db_password = random_id.test_app_rds_master_password.b64_url
  }
}
