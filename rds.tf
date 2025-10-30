# Generate random password for RDS
resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# RDS Subnet Group - uses private subnets
resource "aws_db_subnet_group" "main" {
  name       = "${var.vpc_name}-db-subnet-group"
  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name = "${var.vpc_name}-db-subnet-group"
  }
}

# RDS Parameter Group for PostgreSQL
resource "aws_db_parameter_group" "postgres" {
  name   = "${var.vpc_name}-postgres-params"
  family = "postgres14"

  tags = {
    Name = "${var.vpc_name}-postgres-parameter-group"
  }
}

# RDS Instance
resource "aws_db_instance" "csye6225" {
  identifier        = "csye6225"
  engine            = "postgres"
  engine_version    = "14"
  instance_class    = var.db_instance_class
  allocated_storage = 20
  storage_type      = "gp2"
  storage_encrypted = true

  db_name  = var.db_name
  username = var.db_user
  password = random_password.db_password.result

  db_subnet_group_name   = aws_db_subnet_group.main.name
  parameter_group_name   = aws_db_parameter_group.postgres.name
  vpc_security_group_ids = [aws_security_group.database.id]

  publicly_accessible = false
  multi_az            = false
  skip_final_snapshot = true

  tags = {
    Name = "${var.vpc_name}-rds-instance"
  }
}