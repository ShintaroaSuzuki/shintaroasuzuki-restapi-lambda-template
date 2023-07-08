variable "function_name" {}
variable "memory_size" {}
variable "timeout" { default = 30 }
variable "runtime" { default = "python3.9" }
variable "architectures" { default = ["arm64"] }
variable "layers" { default = [] }
variable "environment" { default = {} }
variable "lambda_exec_role" {}
variable "subnet_ids" { default = [] }
variable "security_group_ids" { default = [] }
