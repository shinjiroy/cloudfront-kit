include "root" {
  path   = find_in_parent_folders("terragrunt.hcl")
  expose = true
}

terraform {
  source = "/apps/modules//cloudfront"
}

locals {
  root_vars         = include.root.locals
  environment       = local.root_vars.environment
  short_environment = local.root_vars.short_environment
  service_name      = local.root_vars.service_name
  module_name       = local.root_vars.module_name
}

inputs = {
  short_environment = local.short_environment
  service_name      = local.service_name

  error_contents_bucket_name = "error-contents"
  hoge_static_bucket_name    = "hoge-static-stg"
  hoge_files_bucket_name     = "hoge-files-stg"

  hoge_com_acm_certificate_arn          = "arn:aws:acm:us-east-1:xxxxxxx:certificate/xxxxxx"
  www_hoge_com_distribution_domain_name = "www.staging.hoge.com"
  hoge_application_domain_name          = "hoge-alb-xxxxxx.xxxxx.elb.amazonaws.com"
  files_viewer_src_path                 = "${get_terragrunt_dir()}/lambda_src/viewer"
  application_default_function_path     = "${get_terragrunt_dir()}/minified/functions/hoge_default.js"
}
