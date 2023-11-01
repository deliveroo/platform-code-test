resource "aws_ecr_repository" "app" {
  force_delete         = true
  image_tag_mutability = "IMMUTABLE"
  name                 = var.app-name

  image_scanning_configuration {
    scan_on_push = true
  }
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "task_role" {
  name                  = var.app-name
  assume_role_policy    = data.aws_iam_policy_document.assume_role_policy.json
  force_detach_policies = true
}

resource "aws_iam_role_policy_attachment" "task_role_execution_policy_attachment" {
  role       = aws_iam_role.task_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "task_role_policy_document" {
  statement {
    actions = [
      "ssm:GetParameters",
    ]

    resources = [
      "arn:aws:ssm:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:parameter/appsecrets/${var.app-name}/*",
    ]
  }
}

resource "aws_iam_policy" "task_role_policy" {
  description = "Access for ${var.app-name}"
  policy      = data.aws_iam_policy_document.task_role_policy_document.json

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy_attachment" "hopper_task_policy_attachment" {
  role       = aws_iam_role.task_role.name
  policy_arn = aws_iam_policy.task_role_policy.arn

  lifecycle {
    create_before_destroy = true
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
      name      = "app"
      image     = var.app-image
      cpu       = 256
      memory    = 512
      essential = true
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
