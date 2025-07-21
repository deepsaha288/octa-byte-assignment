resource "aws_db_subnet_group" "this" {
  name       = "${var.name_prefix}-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "${var.name_prefix}-subnet-group"
  }
}

resource "aws_db_instance" "this" {
  identifier              = "${var.name_prefix}-postgres"
  engine                  = "postgres"
  engine_version          = var.engine_version
  instance_class          = var.instance_class
  allocated_storage       = var.allocated_storage
  max_allocated_storage   = var.max_allocated_storage
  storage_encrypted       = true
  username                = var.username
  password                = var.password
  db_subnet_group_name    = aws_db_subnet_group.this.name
  vpc_security_group_ids  = var.security_group_ids
  skip_final_snapshot     = true
  publicly_accessible     = false
  multi_az                = false

    # Backup settings
  backup_retention_period = 7  # automated backups for 7 days
  backup_window           = "03:00-04:00"

  # Monitoring and other settings
  monitoring_interval     = 60
  enabled_cloudwatch_logs_exports = ["postgresql"]
  performance_insights_enabled = true

  tags = {
    Name = "${var.name_prefix}-postgres"
  }
}
