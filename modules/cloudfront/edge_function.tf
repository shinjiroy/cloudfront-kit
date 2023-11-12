data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type = "Service"
      identifiers = [
        "lambda.amazonaws.com",
        "edgelambda.amazonaws.com",
      ]
    }

    actions = [
      "sts:AssumeRole",
    ]
  }
}

# /files用Lambda@Edge
resource "aws_iam_role" "files_viewer" {
  name               = "${var.service_name}-${var.short_environment}-files-viewer"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
  ]
}
data "archive_file" "files_viewer_src" {
  type        = "zip"
  source_dir  = var.files_viewer_src_path
  output_path = "${var.files_viewer_src_path}/.zip"
}
resource "aws_lambda_function" "files_viewer" {
  provider         = aws.virginia
  filename         = data.archive_file.files_viewer_src.output_path
  function_name    = "${var.service_name}-${var.short_environment}-lambdaedge-files-viewer"
  description      = ""
  role             = aws_iam_role.files_viewer.arn
  handler          = "index.handler"
  source_code_hash = data.archive_file.files_viewer_src.output_base64sha256
  runtime          = "nodejs18.x"
  publish          = true
  memory_size      = 128 # ビューアトリガーの制限
  timeout          = 5   # ビューアトリガーの制限
}

resource "aws_cloudfront_function" "application_default" {
  name    = "${var.service_name}-${var.short_environment}-application-default"
  runtime = "cloudfront-js-1.0"
  comment = ""
  publish = true
  code    = var.application_default_function_path
}
