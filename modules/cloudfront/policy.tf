# キャッシュポリシー
resource "aws_cloudfront_cache_policy" "application" {
  name        = "${var.service_name}-${var.short_environment}-application"
  comment     = ""
  default_ttl = 0 # アプリケーションのキャッシュはオリジン側で調整しましょう
  max_ttl     = 31536000
  min_ttl     = 0
  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"
    }
    headers_config {
      header_behavior = "whitelist"
      headers {
        items = ["ab"]
      }
    }
    query_strings_config {
      query_string_behavior = "allExcept"
      query_strings {
        items = ["utm_source", "utm_medium"] # こんな感じで、広告系のパラメータはキャッシュしない
      }
    }
  }
}

resource "aws_cloudfront_cache_policy" "static" {
  name        = "${var.service_name}-${var.short_environment}-static"
  comment     = ""
  default_ttl = 3600
  max_ttl     = 31536000
  min_ttl     = 0
  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"
    }
    headers_config {
      header_behavior = "none"
    }
    query_strings_config {
      query_string_behavior = "all"
    }
  }
}

# オリジンリクエストポリシー
resource "aws_cloudfront_origin_request_policy" "application" {
  name        = "${var.service_name}-${var.short_environment}-application"
  comment     = ""
  cookies_config {
    cookie_behavior = "all"
  }
  headers_config {
    header_behavior = "allViewer"
  }
  query_strings_config {
    query_string_behavior = "all"
  }
}

# レスポンスヘッダポリシー
resource "aws_cloudfront_response_headers_policy" "default" {
  name        = "${var.service_name}-${var.short_environment}-default"
  comment     = ""
  remove_headers_config {
    dynamic "items" {
      for_each = local.remove_headers
      content {
        header = items.value
      }
    }
  }
}
