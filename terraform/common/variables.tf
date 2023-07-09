variable "env_name" {}
variable "db_backup_retention_period" {}
variable "db_min_capacity" { default = 0.5 }
variable "db_max_capacity" { default = 1.0 }
variable "db_instance_num" {}
variable "db_instance_type" {}
variable "stg_ns_record" {}
variable "prd_ns_record" {}

locals {
  domain      = "sonawaru.com"
  dev_domain  = "dev-app.${local.domain}"
  stg_domain  = "stg-app.${local.domain}"
  prd_domain  = "app.${local.domain}"
  site_domain = var.env_name == "dev" ? local.dev_domain : var.env_name == "stg" ? local.stg_domain : local.prd_domain
  app_name    = "sonawaru"
}
