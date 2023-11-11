locals {
  # 常に削除するレスポンスヘッダ
  remove_headers = ["Server"]

  # 本番以外は色々絞る
  distribution_price_class         = var.short_environment == "prod" ? "PriceClass_All" : "PriceClass_200"
  geo_restriction_restriction_type = var.short_environment == "prod" ? "none" : "whitelist"
  geo_restriction_locations        = var.short_environment == "prod" ? [] : ["JP"]
}

# カスタムエラーレスポンス用のファイルがあるバケット
# 静的ウェブサイトホスティングされてる想定
data "aws_s3_bucket" "error_contents" {
  bucket = var.error_contents_bucket_name
}

# 以下、サービス固有のコンテンツ用バケット

data "aws_s3_bucket" "hoge_static" {
  bucket = var.hoge_static_bucket_name
}

resource "aws_cloudfront_origin_access_control" "hoge_static" {
  name                              = "${var.service_name}-${var.short_environment}-hoge-static"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

data "aws_s3_bucket" "hoge_files" {
  bucket = var.hoge_files_bucket_name
}

resource "aws_cloudfront_origin_access_control" "hoge_files" {
  name                              = "${var.service_name}-${var.short_environment}-hoge-files"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}
