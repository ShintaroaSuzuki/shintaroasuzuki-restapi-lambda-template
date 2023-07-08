# エイリアス設定したプロバイダは明示的な参照しかされない
# CloudFront用ACMはバージニア北部にしないといけない
provider "aws" {
  region = "us-east-1"
  alias  = "virginia"
}
