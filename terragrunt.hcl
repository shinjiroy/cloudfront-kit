locals {
  environment_vars = read_terragrunt_config(find_in_parent_folders("environment.hcl"))

  environment       = local.environment_vars.locals.environment
  short_environment = local.environment_vars.locals.short_environment
  state_bucket      = local.environment_vars.locals.state_bucket

  service_name = "hogeservice"
  module_name  = "cdn"

  default_region = get_env("AWS_REGION")
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.default_region}"
  default_tags {
    tags = {
      environment = "${local.environment}"
      terraform   = "true"
      service     = "${local.service_name}"
      module      = "${local.module_name}"
    }
  }
}

provider "aws" {
  alias  = "virginia"
  region = "us-east-1"
  default_tags {
    tags = {
      environment = "${local.environment}"
      terraform   = "true"
      service     = "${local.service_name}"
      module      = "${local.module_name}"
    }
  }
}
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
EOF
}

remote_state {
  backend = "local"
  config = {
    path = "${get_parent_terragrunt_dir()}/state/${path_relative_to_include()}/terraform.tfstate"
  }

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

# remote_state {
#   backend = "s3"
#   config = {
#     encrypt = true
#     region  = local.environment_vars.locals.state_bucket_region
#     bucket  = local.environment_vars.locals.state_bucket
#     key     = "${local.service_name}/${path_relative_to_include()}/terraform.tfstate"
#   }
#   generate = {
#     path      = "backend.tf"
#     if_exists = "overwrite_terragrunt"
#   }
# }
