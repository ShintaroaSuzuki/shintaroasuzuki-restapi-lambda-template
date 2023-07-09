terraform {
  backend "s3" {
    bucket = "${local.app_name}-tfstate"
    key    = "terraform.tfstate"
    region = "ap-northeast-1"
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

module "common" {
  source                     = "../../common"
  env_name                   = "dev"
  db_backup_retention_period = 30 # DBのバックアップの間隔(日)
  db_instance_num            = 1  # DBのインスタンス数
  db_instance_type           = "db.t3.medium"
  stg_ns_record              = "" # Stgデプロイ後にStgアカウントに作成されたRoute53のNSレコードを設定する
  prd_ns_record              = "" # Prdデプロイ後にPrdアカウントに作成されたRoute53のNSレコードを設定する
  from_email                 = "" # TODO: 送信元メールアドレ決まったら設定する
}
