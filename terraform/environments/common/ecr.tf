resource "aws_ecr_repository" "test_app" {
  force_delete         = true
  image_tag_mutability = "MUTABLE"
  name                 = var.app_name

  image_scanning_configuration {
    scan_on_push = true
  }
}
