resource "aws_cloudfront_distribution" "www_hoge_com" {
  aliases             = [var.www_hoge_com_distribution_domain_name]
  comment             = var.www_hoge_com_distribution_domain_name
  default_root_object = null
  enabled             = true
  http_version        = "http2"
  is_ipv6_enabled     = true
  price_class         = local.distribution_price_class
  retain_on_delete    = false
  wait_for_deployment = true
  web_acl_id          = var.application_web_acl_id

  custom_error_response {
    error_code         = 403
    response_code      = 403
    response_page_path = "/error/forbidden.html"
  }

  custom_error_response {
    error_code         = 404
    response_code      = 404
    response_page_path = "/error/not_found.html"
  }

  custom_error_response {
    error_code         = 503
    response_code      = 503
    response_page_path = "/error/server_error.html"
  }

  custom_error_response {
    error_code         = 504
    response_code      = 504
    response_page_path = "/error/server_error.html"
  }

  default_cache_behavior {
    allowed_methods            = ["GET", "HEAD", "OPTIONS", "POST", "PUT", "DELETE", "PATCH"]
    cache_policy_id            = aws_cloudfront_cache_policy.application.id
    cached_methods             = ["GET", "HEAD"]
    compress                   = true
    field_level_encryption_id  = null
    origin_request_policy_id   = aws_cloudfront_origin_request_policy.application.id
    realtime_log_config_arn    = null
    response_headers_policy_id = aws_cloudfront_response_headers_policy.default.id
    smooth_streaming           = false
    target_origin_id           = "application"
    trusted_key_groups         = []
    trusted_signers            = []
    viewer_protocol_policy     = "allow-all"

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.application_default.arn
    }
  }

  ordered_cache_behavior {
    allowed_methods            = ["GET", "HEAD"]
    cache_policy_id            = aws_cloudfront_cache_policy.static.id
    cached_methods             = ["GET", "HEAD"]
    compress                   = true
    field_level_encryption_id  = null
    origin_request_policy_id   = null
    path_pattern               = "/static/*"
    realtime_log_config_arn    = null
    response_headers_policy_id = aws_cloudfront_response_headers_policy.default.id
    smooth_streaming           = false
    target_origin_id           = "hoge_static"
    trusted_key_groups         = []
    trusted_signers            = []
    viewer_protocol_policy     = "allow-all"
  }

  ordered_cache_behavior {
    allowed_methods            = ["GET", "HEAD", "OPTIONS"]
    cache_policy_id            = aws_cloudfront_cache_policy.files.id
    cached_methods             = ["GET", "HEAD"]
    compress                   = true
    field_level_encryption_id  = null
    origin_request_policy_id   = null
    path_pattern               = "/files/*"
    realtime_log_config_arn    = null
    response_headers_policy_id = aws_cloudfront_response_headers_policy.files.id
    smooth_streaming           = false
    target_origin_id           = "hoge_files"
    trusted_key_groups         = []
    trusted_signers            = []
    viewer_protocol_policy     = "allow-all"

    lambda_function_association {
      event_type   = "viewer-request"
      lambda_arn   = aws_lambda_function.files_viewer.qualified_arn
      include_body = false
    }
  }

  # カスタムエラーレスポンス用ビヘイビア
  ordered_cache_behavior {
    allowed_methods            = ["GET", "HEAD"]
    cache_policy_id            = data.aws_cloudfront_cache_policy.caching_disabled.id
    cached_methods             = ["GET", "HEAD"]
    compress                   = true
    field_level_encryption_id  = null
    origin_request_policy_id   = null
    path_pattern               = "/error/*"
    realtime_log_config_arn    = null
    response_headers_policy_id = aws_cloudfront_response_headers_policy.default.id
    smooth_streaming           = false
    target_origin_id           = "error_contents"
    trusted_key_groups         = []
    trusted_signers            = []
    viewer_protocol_policy     = "allow-all"
  }

  # アプリケーションサーバー
  origin {
    connection_attempts      = 3
    connection_timeout       = 10
    domain_name              = var.hoge_application_domain_name
    origin_access_control_id = null
    origin_id                = "application"
    origin_path              = null

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_keepalive_timeout = 5
      origin_protocol_policy   = "https-only"
      origin_read_timeout      = 60
      origin_ssl_protocols     = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  # hoge_static
  origin {
    connection_attempts      = 3
    connection_timeout       = 10
    domain_name              = data.aws_s3_bucket.hoge_static.bucket_regional_domain_name
    origin_id                = "hoge_static"
    origin_path              = null
    origin_access_control_id = aws_cloudfront_origin_access_control.hoge_static.id
  }

  # hoge_files
  origin {
    connection_attempts      = 3
    connection_timeout       = 10
    domain_name              = data.aws_s3_bucket.hoge_files.bucket_regional_domain_name
    origin_id                = "hoge_files"
    origin_path              = null
    origin_access_control_id = aws_cloudfront_origin_access_control.hoge_files.id
  }

  # error_contents
  origin {
    connection_attempts      = 3
    connection_timeout       = 10
    domain_name              = data.aws_s3_bucket.error_contents.website_endpoint
    origin_access_control_id = null
    origin_id                = "error_contents"
    origin_path              = "/hoge"

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_keepalive_timeout = 5
      origin_protocol_policy   = "http-only"
      origin_read_timeout      = 60
      origin_ssl_protocols     = ["TLSv1.2"]
    }
  }

  restrictions {
    geo_restriction {
      locations        = local.geo_restriction_locations
      restriction_type = local.geo_restriction_restriction_type
    }
  }

  viewer_certificate {
    acm_certificate_arn            = var.hoge_com_acm_certificate_arn
    cloudfront_default_certificate = false
    iam_certificate_id             = null
    minimum_protocol_version       = "TLSv1.2_2021"
    ssl_support_method             = "sni-only"
  }

  logging_config {
    bucket          = "hoge-accesslog.s3.amazonaws.com"
    include_cookies = false
    prefix          = "cloudfront_logs/www-hoge-com-${var.short_environment}"
  }
}

# 追加のメトリクス
# 不要な場合はリソース自体を削除する
resource "aws_cloudfront_monitoring_subscription" "www_hoge_com" {
  distribution_id = aws_cloudfront_distribution.www_hoge_com.id

  monitoring_subscription {
    realtime_metrics_subscription_config {
      realtime_metrics_subscription_status = "Enabled"
    }
  }
}
