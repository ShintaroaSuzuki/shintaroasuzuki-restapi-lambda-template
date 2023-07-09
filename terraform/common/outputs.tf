output "instance_id" {
  value = aws_instance.ec2_bastion.id
}

output "db_host" {
  value = aws_rds_cluster.${local.app_name}_db.endpoint
}

output "db_secret" {
  value = aws_rds_cluster.${local.app_name}_db.master_user_secret[0].secret_arn
}
