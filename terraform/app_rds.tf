resource "aws_db_subnet_group" "test_app" {
  name       = var.app_name
  subnet_ids = [aws_subnet.subnet_dbs_a.id, aws_subnet.subnet_dbs_b.id, aws_subnet.subnet_dbs_c.id]

  tags = {
    Name = var.app_name
  }
}

resource "aws_db_parameter_group" "test_app" {
  name   = var.app_name
  family = "postgres15"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "test_app_rds_public" {
  name        = "${var.app_name}-rds"
  description = "Allow traffic for ${var.app_name} RDS"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.app_name}-rds"
  }
}

resource "random_id" "test_app_rds_master_password" {
  byte_length = 24
  keepers = {
    identifier = var.app_name
  }
}

resource "aws_rds_cluster" "test_app" {
  backup_retention_period = 1
  cluster_identifier      = var.app_name
  db_subnet_group_name    = aws_db_subnet_group.test_app.name
  engine                  = "aurora-postgresql"
  engine_mode             = "provisioned"
  engine_version          = "15"
  database_name           = "main"
  master_password         = random_id.test_app_rds_master_password.b64_url
  master_username         = var.app_rds_master_username
  skip_final_snapshot     = true
  tags = {
    Name = var.app_name
  }
  vpc_security_group_ids = [aws_security_group.test_app_rds_public.id]

  serverlessv2_scaling_configuration {
    max_capacity = 1.0
    min_capacity = 0.5
  }
}

resource "aws_rds_cluster_instance" "test_app" {
  cluster_identifier = aws_rds_cluster.test_app.id
  instance_class     = "db.serverless"
  engine             = aws_rds_cluster.test_app.engine
  engine_version     = aws_rds_cluster.test_app.engine_version
  tags = {
    Name = var.app_name
  }
}
