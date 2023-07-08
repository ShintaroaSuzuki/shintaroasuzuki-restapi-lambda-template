data "aws_route53_zone" "main" {
  count   = var.env_name == "dev" ? 1 : 0 # ドメインはDevでのみ管理する
  zone_id = "Z03293182ZPVJ0ZO3QGP0"       # ドメイン購入時に自動作成されたホストゾーンのID
}

resource "aws_route53_zone" "subdomain" {
  count = var.env_name != "dev" ? 1 : 0 # サブドメインホストゾーンはDev以外で作成する
  name  = local.site_domain
}

locals {
  zone_id = var.env_name == "dev" ? data.aws_route53_zone.main[0].zone_id : aws_route53_zone.subdomain[0].zone_id
}

resource "aws_route53_record" "dev_to_stg" {
  # DevアカウントからStgアカウントへのサブドメインの使用許可
  count   = var.env_name == "dev" && var.stg_ns_record != "" ? 1 : 0 # Devのみ作成
  zone_id = local.zone_id
  ttl     = 172800
  name    = local.stg_domain
  type    = "NS"
  records = [var.stg_ns_record]
}

resource "aws_route53_record" "dev_to_prd" {
  # DevアカウントからPrdアカウントへのサブドメインの使用許可
  count   = var.env_name == "dev" && var.prd_ns_record != "" ? 1 : 0 # Devのみ作成
  zone_id = local.zone_id
  ttl     = 172800
  name    = local.prd_domain
  type    = "NS"
  records = [var.prd_ns_record]
}

resource "aws_route53_record" "subdomain" {
  zone_id = local.zone_id
  name    = local.site_domain
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.cf.domain_name
    zone_id                = aws_cloudfront_distribution.cf.hosted_zone_id
    evaluate_target_health = false
  }
}
