resource "aws_wafv2_web_acl" "hoge" {
  name        = "${var.service_name}-${var.short_environment}-cloudfront-hoge"
  description = ""
  scope       = "CLOUDFRONT"
  provider    = aws.virginia

  default_action {
    allow {}
  }

  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 10

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesCommonRuleSetMetric"
      sampled_requests_enabled   = false
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${title(var.service_name)}${title(var.short_environment)}CloudfrontHogeWebACLMetric"
    sampled_requests_enabled   = false
  }
}
