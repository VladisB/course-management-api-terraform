resource "aws_security_group" "rds" {
  vpc_id = var.vpc_id
  name   = "${var.env_prefix}-rds-sg"

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.jumpbox_sg_id]
  }

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.codebuild_test_sg_id]
  }

  tags = {
    Name        = "${var.env_prefix}-rds-sg"
    Environment = "dev"
  }
}

resource "aws_db_subnet_group" "main" {
  name       = "main"
  subnet_ids = var.vpc_private_subnets
}

data "aws_secretsmanager_secret_version" "db_creds" {
  secret_id = var.db_secret_id
}

locals {
  db_creds = jsondecode(
    data.aws_secretsmanager_secret_version.db_creds.secret_string
  )
}

resource "aws_db_instance" "postgres" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "postgres"
  engine_version       = "13"
  instance_class       = "db.t3.micro"
  identifier           = "mydb"
  parameter_group_name = "default.postgres13"

  password = local.db_creds.db_password
  username = local.db_creds.db_username

  skip_final_snapshot = true

  db_name = var.db_name

  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name

  tags = {
    Name        = "${var.env_prefix}-postgres"
    Environment = "dev"
  }
}