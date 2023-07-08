variable "lambda_exec_role" {}
variable "db_name" {}
variable "proxy_endpoint" {}
variable "subnet_ids" {}
variable "security_group_ids" {}
variable "client_id" {}
variable "user_pool_id" {}
variable "domain" {}

locals {
  lambda_runtime = "python3.9"
  lambda_arch    = ["arm64"]
}
