resource "aws_ecr_repository" "app" {
  force_delete         = true
  image_tag_mutability = "IMMUTABLE"
  name                 = var.app-name

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_cloudwatch_log_group" "test_app" {
  name              = "/aws/ecs/${var.app-name}"
  retention_in_days = 3

  tags = {
    Name = var.app-name
  }
}

resource "aws_security_group" "test_app" {
  name        = var.app-name
  description = "Allow traffic for ${var.app-name}"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = var.app-name
  }
}

resource "aws_ecs_task_definition" "test_app" {

  container_definitions = jsonencode([
    {
      command   = ["/app"]
      name      = "app"
      image     = var.app-image
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
  family                   = var.app-name
  memory                   = 512
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  tags = {
    Name = var.app-name
  }
  task_role_arn = aws_iam_role.task_role.arn
}

resource "aws_ecs_service" "test_app" {
  cluster       = aws_ecs_cluster.apps.id
  desired_count = 1
  launch_type   = "FARGATE"
  name          = var.app-name
  network_configuration {
    security_groups = [aws_security_group.test_app.id]
    subnets         = [aws_subnet.subnet_apps_a.id]
  }
  task_definition = aws_ecs_task_definition.test_app.arn
  tags = {
    Name = var.app-name
  }
}
