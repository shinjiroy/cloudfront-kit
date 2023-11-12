include "root" {
  path   = find_in_parent_folders("terragrunt.hcl")
  expose = true
}

terraform {
  source = "/apps/modules//waf"
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
}
