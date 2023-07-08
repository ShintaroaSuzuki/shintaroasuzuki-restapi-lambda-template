resource "aws_cloudfront_distribution" "cf" {
  aliases = [local.site_domain]

  origin {
    domain_name = replace("${aws_apigatewayv2_api.http_api.api_endpoint}", "/^https?://([^/]*).*/", "$1")
    origin_id   = aws_apigatewayv2_api.http_api.id
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1"]
      origin_read_timeout    = 60
    }
  }

  enabled             = true
  is_ipv6_enabled     = true

  ordered_cache_behavior {
    path_pattern     = "/api/*"
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_apigatewayv2_api.http_api.id

    forwarded_values {
      query_string = true
      headers      = ["Authorization"]

      cookies {
        forward = "all"
      }
    }

    min_ttl                = 0
    default_ttl            = 1
    max_ttl                = 1
    compress               = false
    viewer_protocol_policy = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn            = aws_acm_certificate_validation.acm_cert.certificate_arn
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1"
  }
}

resource "aws_cloudfront_origin_access_identity" "for_client" {}
