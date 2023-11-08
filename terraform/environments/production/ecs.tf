resource "aws_ecs_cluster" "apps" {
  name = "apps"
}

resource "aws_ecs_cluster_capacity_providers" "main" {
  capacity_providers = ["FARGATE"]
  cluster_name       = aws_ecs_cluster.apps.name

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}
