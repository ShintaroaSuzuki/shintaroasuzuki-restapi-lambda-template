locals {
  availability_zones = ["ap-northeast-1a", "ap-northeast-1c"] # インスタンスを配置するazの指定
}

resource "aws_rds_cluster" "sonawaru_app_db" {
  cluster_identifier_prefix       = "sonawaru-app-db"
  availability_zones              = local.availability_zones
  backup_retention_period         = var.db_backup_retention_period
  database_name                   = "sonawaru_app_db"
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.sonawaru_app_db.name
  db_subnet_group_name            = aws_db_subnet_group.sonawaru_app_db.name
  deletion_protection             = true
  engine                          = "aurora-mysql"
  engine_mode                     = "provisioned" # aurora serverless v2はprovisionedモード固定
  engine_version                  = "8.0.mysql_aurora.3.02.0"
  final_snapshot_identifier       = "sonawaru-app-db-final-snapshot"
  manage_master_user_password     = true
  master_username                 = "sonawaru"
  port                            = 3306
  vpc_security_group_ids          = [aws_security_group.sonawaru_app_db.id]

  serverlessv2_scaling_configuration {
    min_capacity = var.db_min_capacity
    max_capacity = var.db_max_capacity
  }

  lifecycle {
    ignore_changes = [
      master_password,
      availability_zones
    ]
  }
}

resource "aws_rds_cluster_instance" "sonawaru_app_db" {
  count                      = var.db_instance_num
  availability_zone          = local.availability_zones[count.index % length(local.availability_zones)] # instance数に応じて順次az設定
  cluster_identifier         = aws_rds_cluster.sonawaru_app_db.id
  identifier_prefix          = "sonawaru-app-db-instance-"
  engine                     = aws_rds_cluster.sonawaru_app_db.engine
  engine_version             = aws_rds_cluster.sonawaru_app_db.engine_version
  instance_class             = var.db_instance_type
  db_subnet_group_name       = aws_db_subnet_group.sonawaru_app_db.name
  db_parameter_group_name    = aws_db_parameter_group.sonawaru_app_db.name
  publicly_accessible        = false
  auto_minor_version_upgrade = false
}

resource "aws_db_subnet_group" "sonawaru_app_db" {
  name        = "sonawaru-app-db"
  description = "rds subnet group"
  subnet_ids = [
    aws_subnet.private_1a.id,
    aws_subnet.private_1c.id
  ]
}

resource "aws_security_group" "sonawaru_app_db" {
  name        = "sonawaru-app-db"
  description = "RDS service security group"
  vpc_id      = aws_vpc.vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_rds_cluster_parameter_group" "sonawaru_app_db" {
  name   = "sonawaru-app-db"
  family = "aurora-mysql8.0"

  parameter {
    name  = "character_set_database"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }

  parameter {
    name  = "collation_server"
    value = "utf8mb4_bin"
  }
}

resource "aws_db_parameter_group" "sonawaru_app_db" {
  name   = "db-instance"
  family = "aurora-mysql8.0"
}
