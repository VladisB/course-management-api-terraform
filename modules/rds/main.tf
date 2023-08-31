resource "aws_security_group" "rds" {
  vpc_id = var.vpc_id
  name = "${var.env_prefix}-rds-sg"

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    security_groups = [var.jumpbox_sg_id]
  }  

  tags = {
      Name = "${var.env_prefix}-rds-sg"
      Environment = "dev"
    }
}

resource "aws_db_subnet_group" "main" {
  name       = "main"
  subnet_ids = var.vpc_private_subnets
}

resource "aws_db_instance" "postgres" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "postgres"
  engine_version       = "13"
  instance_class       = "db.t3.micro"
  identifier           = "mydb"
  parameter_group_name = "default.postgres13"
  
  password             = "yourpassword" // TODO: Change this to something secure
  username             = "postgres" // TODO: Change this to something secure 
  
  skip_final_snapshot  = true

  db_name                  = var.db_name

  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name     = aws_db_subnet_group.main.name

  tags = {
    Name = "${var.env_prefix}-postgres"
    Environment = "dev"
  }
}