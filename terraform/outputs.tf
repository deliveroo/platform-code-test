output "db_host" {
  value = aws_rds_cluster.test_app.endpoint
}

output "db_user" {
  value = var.app_rds_master_username
}

output "db_password" {
  value     = random_id.test_app_rds_master_password.b64_url
  sensitive = true
}
