resource "aws_cloudwatch_log_group" "test_app" {
  name              = "/aws/ecs/${var.app_name}"
  retention_in_days = 3

  tags = {
    Name = var.app_name
  }
}

resource "aws_security_group" "test_app" {
  name        = var.app_name
  description = "Allow traffic for ${var.app_name}"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["10.2.0.0/16"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.app_name
  }
}

resource "aws_ecs_task_definition" "test_app" {

  container_definitions = jsonencode([
    {
      command   = ["/app"]
      name      = "app"
      image     = data.aws_ecr_image.app_image.image_uri
      cpu       = 256
      memory    = 512
      essential = true
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "${aws_cloudwatch_log_group.test_app.name}"
          awslogs-region        = data.aws_region.current.id
          awslogs-stream-prefix = "ecs"
        }
      }
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
        }
      ]
    }
  ])
  cpu                      = 256
  execution_role_arn       = aws_iam_role.task_role.arn
  family                   = var.app_name
  memory                   = 512
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  tags = {
    Name = var.app_name
  }
  task_role_arn = aws_iam_role.task_role.arn
}

resource "aws_ecs_service" "test_app" {
  cluster         = aws_ecs_cluster.apps.id
  desired_count   = 1
  launch_type     = "FARGATE"
  name            = var.app_name
  task_definition = aws_ecs_task_definition.test_app.arn
  tags = {
    Name = var.app_name
  }

  load_balancer {
    container_name   = "app"
    container_port   = 8080
    target_group_arn = aws_lb_target_group.test_app_public.arn
  }

  network_configuration {
    security_groups = [aws_security_group.test_app.id]
    subnets         = [aws_subnet.subnet_apps_a.id]
  }
}
