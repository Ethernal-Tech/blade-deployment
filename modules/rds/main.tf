resource "aws_secretsmanager_secret" "blockscout_rds_password" {
  name                    = "blockscout-rds-password-${var.base_id}"
  recovery_window_in_days = 0
}
resource "aws_secretsmanager_secret_version" "blockscout_rds_password" {
  secret_id     = aws_secretsmanager_secret.blockscout_rds_password.id
  secret_string = var.explorer_rds_master_password
}

resource "aws_db_subnet_group" "explorer" {
  name       = "blockscout-${var.base_id}"
  subnet_ids = var.devnet_private_subnet_ids
}

resource "aws_rds_cluster" "explorer" {
  count                     = var.explorer_count > 0 ? 1 : 0
  cluster_identifier        = "explorer-${var.base_id}"
  engine                    = "aurora-postgresql"
  availability_zones        = slice(var.zones, 0, 3)
  db_subnet_group_name      = aws_db_subnet_group.explorer.name
  database_name             = "explorer"
  master_username           = "blockscout"
  master_password           = aws_secretsmanager_secret_version.blockscout_rds_password.secret_string
  backup_retention_period   = 5
  preferred_backup_window   = "12:00-14:00"
  skip_final_snapshot       = true
  final_snapshot_identifier = "explorer-${var.base_id}-final-snapshot"

  engine_mode = "provisioned"
  #  engine_version = "13.6"

  serverlessv2_scaling_configuration {
    max_capacity = 3.0
    min_capacity = 1.0
  }
}

resource "aws_rds_cluster_instance" "explorer" {
  count              = var.explorer_count > 0 ? 1 : 0
  cluster_identifier = aws_rds_cluster.explorer[count.index].id
  instance_class     = "db.serverless"
  engine             = aws_rds_cluster.explorer[count.index].engine
  engine_version     = aws_rds_cluster.explorer[count.index].engine_version
}
