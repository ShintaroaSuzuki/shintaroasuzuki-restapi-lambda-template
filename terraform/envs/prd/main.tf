terraform {
  backend "s3" {
    bucket = "sonawaru-app-prd-tfstate"
    key    = "terraform.tfstate"
    region = "ap-northeast-1"
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

module "common" {
  source                     = "../../common"
  env_name                   = "prd"
  db_backup_retention_period = 30  # DBのバックアップの間隔(日)
  db_min_capacity            = 0.5 # DBのオートスケールの最小値 1あたり2GBのCPU
  db_max_capacity            = 8   # DBのオートスケールの最大値
  db_instance_num            = 3   # DBのインスタンス数
  db_instance_type           = "db.serverless"
  from_email                 = "" # TODO: 送信元メールアドレ決まったら設定する
}
