resource "aws_security_group" "jump-box-sg" {
  name   = "${var.env_prefix}-jump-box-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }


  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    prefix_list_ids = []
  }

  tags = {
    Name        = "${var.env_prefix}-jump-box-sg"
    Environment = "dev"
  }
}

resource "aws_key_pair" "ssh-key" {
  key_name   = var.ec2_key_name
  public_key = file(var.public_key_location)
  tags = {
    Name = "${var.env_prefix}-ssh-key"
  }
}

data "aws_ami" "latest-amazon-linux-2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "jumpbox-instance" {
  ami           = data.aws_ami.latest-amazon-linux-2.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.ssh-key.key_name

  vpc_security_group_ids = [aws_security_group.jump-box-sg.id]
  availability_zone      = var.availability_zone
  subnet_id              = var.subnet_id

  associate_public_ip_address = true

  user_data = <<-EOF
            #!/bin/bash
            sudo yum update -y
            sudo yum install -y postgresql
            EOF

  tags = {
    Name = "${var.env_prefix}-jump-box"
  }
}