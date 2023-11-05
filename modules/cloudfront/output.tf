# OAC認証用のバケットポリシー
output "hoge_bucket_oac_statement" {
  value = data.aws_iam_policy_document.hoge_bucket.json
}

data "aws_iam_policy_document" "hoge_bucket" {
  statement {
    sid = "${var.service_name}-${var.short_environment}-cloudfront_AllowAccess"

    principals {
      type = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = [
      "s3:GetObject",
      "s3:ListBucket", # これが無いと、オブジェクトが無い時403が出る
    ]

    resources = [
      "${data.aws_s3_bucket.hoge_bucket.arn}",
      "${data.aws_s3_bucket.hoge_bucket.arn}/*",
    ]

    condition {
      test = "StringEquals"
      variable = "aws:SourceArn"
      values = [
        aws_cloudfront_distribution.www_hoge_com.arn
      ]
    }
  }
}
