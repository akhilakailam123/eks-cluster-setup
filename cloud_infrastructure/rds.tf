resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds_db_subnet_group-${var.environment}"
  subnet_ids = local.public_subnets_ids
  tags = {
    Name = "rds_db_subnet_group-${var.environment}"
  }
}

resource "aws_db_instance" "mysql_db_instance" {
  identifier              = "ecom-db-${var.environment}"
  allocated_storage       = 20
  backup_retention_period = 3
  backup_window           = "22:52-23:22"
  engine                  = "mysql"
  engine_version          = "8.0.39"
  availability_zone       = "eu-central-1b"
  instance_class          = "db.t4g.medium"
  username                = var.rds_db_username
  password                = var.rds_db_password
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  db_subnet_group_name    = aws_db_subnet_group.rds_subnet_group.name
  parameter_group_name    = "default.mysql8.0"
  kms_key_id              = data.aws_kms_alias.rds_kms_key.arn
  storage_encrypted       = true
  multi_az                = false
  port                    = 3306
  publicly_accessible     = true
  storage_type            = "gp2"

  lifecycle {
    ignore_changes = [kms_key_id]
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "rds_sg-${var.environment}"
  description = "Controlling traffic going to MySQL RDS"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "Allow MySQL traffic from any address"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "rds_sg-${var.environment}"
  }
}
