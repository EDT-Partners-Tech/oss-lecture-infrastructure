# © [2025] EDT&Partners. Licensed under CC BY 4.0.
resource "aws_cognito_user_pool" "main" {
  name = "${var.project}-${var.region}-pool"


  # Password Policy
  password_policy {
    minimum_length                   = 8
    require_uppercase                = true
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = true
    temporary_password_validity_days = 7
  }

  # Deletion Protection
  deletion_protection = "ACTIVE"


  # Required standard attributes
  schema {
    name                = "email"
    attribute_data_type = "String"
    required            = true
    mutable             = true
    string_attribute_constraints {
      min_length = 0
      max_length = 2048
    }
  }

  schema {
    name                = "given_name"
    attribute_data_type = "String"
    required            = true
    mutable             = true
    string_attribute_constraints {
      min_length = 0
      max_length = 2048
    }
  }

  schema {
    name                = "locale"
    attribute_data_type = "String"
    required            = true
    mutable             = true
    string_attribute_constraints {
      min_length = 0
      max_length = 2048
    }
  }
  schema {
    name                = "family_name"
    attribute_data_type = "String"
    required            = true
    mutable             = true
    string_attribute_constraints {
      min_length = 0
      max_length = 2048
    }
  }

  # Custom attributes
  schema {
    name                = "role"
    attribute_data_type = "String"
    mutable             = true
    required            = false
  }
  schema {
    name                = "avatar"
    attribute_data_type = "String"
    mutable             = true
    required            = false
  }


  # Auto verified attributes
  auto_verified_attributes = ["email"]

  # Username configuration
  username_attributes = ["email"]

  # Account recovery setting
  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }
  lifecycle {
    ignore_changes = [schema]
  }

}


resource "aws_cognito_user_pool_client" "pool_client" {
  name         = "${var.project}-${var.region}-pool-client"
  user_pool_id = aws_cognito_user_pool.main.id

  generate_secret = false
  token_validity_units {
    access_token  = "minutes"
    id_token      = "minutes"
    refresh_token = "days"
  }

  access_token_validity  = 60 # in minutes
  id_token_validity      = 60 # in minutes
  refresh_token_validity = 30 # in days

  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_ADMIN_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]

  allowed_oauth_flows                  = ["code", "implicit"]
  allowed_oauth_scopes                 = ["email", "openid", "profile"]
  allowed_oauth_flows_user_pool_client = true

  callback_urls = ["https://example.com/callback"]
  logout_urls   = ["https://example.com/logout"]

  prevent_user_existence_errors = "ENABLED"
}


locals {
  cognito_env = {
    COGNITO_USERPOOL_ID   = aws_cognito_user_pool.main.id
    COGNITO_APP_CLIENT_ID = aws_cognito_user_pool_client.pool_client.id
  }
  module_variables = flatten([
    for name, value in local.cognito_env : {
      name        = "/lecture/global/${name}"
      value       = "${value}"
      type        = "String"
      overwrite   = "true"
      description = ""
    }
  ])
}

module "ssm_dynamic_variables" {
  source               = "cloudposse/ssm-parameter-store/aws"
  ignore_value_changes = "true"
  parameter_write      = local.module_variables
}
