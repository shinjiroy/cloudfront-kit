# OAC認証用のバケットポリシー
output "hoge_static_oac_statement" {
  value = data.aws_iam_policy_document.hoge_static.json
}

data "aws_iam_policy_document" "hoge_static" {
  statement {
    sid = "${var.service_name}-${var.short_environment}-cloudfront_AllowAccess"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]

    resources = [
      "${data.aws_s3_bucket.hoge_static.arn}",
      "${data.aws_s3_bucket.hoge_static.arn}/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values = [
        aws_cloudfront_distribution.www_hoge_com.arn
      ]
    }
  }
}

output "hoge_files_oac_statement" {
  value = data.aws_iam_policy_document.hoge_files.json
}

data "aws_iam_policy_document" "hoge_files" {
  statement {
    sid = "${var.service_name}-${var.short_environment}-cloudfront_AllowAccess"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]

    resources = [
      "${data.aws_s3_bucket.hoge_files.arn}",
      "${data.aws_s3_bucket.hoge_files.arn}/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values = [
        aws_cloudfront_distribution.www_hoge_com.arn
      ]
    }
  }
}
