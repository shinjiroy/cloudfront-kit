resource "aws_cloudfront_function" "application" {
  name    = "${var.service_name}-${var.short_environment}-application"
  runtime = "cloudfront-js-1.0"
  comment = ""
  publish = true
  code    = file("${path.module}/function.js")
}


