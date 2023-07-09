terraform {
  backend "s3" {
    bucket = "${local.app_name}-stg-tfstate"
    key    = "terraform.tfstate"
    region = "ap-northeast-1"
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

module "common" {
  source                     = "../../common"
  env_name                   = "stg"
  db_backup_retention_period = 30 # DBのバックアップの間隔(日)
  db_instance_num            = 1  # DBのインスタンス数
  db_instance_type           = "db.t3.medium"
  from_email                 = "" # TODO: 送信元メールアドレ決まったら設定する
}
