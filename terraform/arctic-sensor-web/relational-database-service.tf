# Relational Database Service
resource "aws_db_instance" "frost-database-1" {
  allocated_storage                     = 25
  auto_minor_version_upgrade            = true
  availability_zone                     = "us-west-2a"
  backup_retention_period               = 3
  backup_window                         = "12:56-13:26"
  ca_cert_identifier                    = "rds-ca-2019"
  copy_tags_to_snapshot                 = true
  db_subnet_group_name                  = "default-${aws_vpc.sensorthings-vpc.id}"
  delete_automated_backups              = true
  deletion_protection                   = true
  enabled_cloudwatch_logs_exports       = [
      "postgresql",
  ]
  engine                                = "postgres"
  engine_version                        = "11.8"
  iam_database_authentication_enabled   = false
  identifier                            = "frost-database-1"
  instance_class                        = "db.t2.micro"
  iops                                  = 0
  license_model                         = "postgresql-license"
  maintenance_window                    = "mon:09:09-mon:09:39"
  max_allocated_storage                 = 100
  monitoring_interval                   = 0
  multi_az                              = false
  option_group_name                     = "default:postgres-11"
  parameter_group_name                  = "default.postgres11"
  performance_insights_enabled          = true
  performance_insights_kms_key_id       = "arn:aws:kms:us-west-2:041053977358:key/c93b8251-33fc-4ea1-8f52-423c5b45e065"
  performance_insights_retention_period = 7
  port                                  = 5432
  publicly_accessible                   = true
  security_group_names                  = []
  skip_final_snapshot                   = true
  storage_encrypted                     = false
  storage_type                          = "gp2"
  tags                                  = {
      "arcticconnect" = "arcticsensorweb"
  }
  username                              = "postgres"
  vpc_security_group_ids                = [
      aws_security_group.airflow-group-1.id,
      aws_security_group.frost-server-group.id,
  ]

  timeouts {}
}

