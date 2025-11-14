# © [2025] EDT&Partners. Licensed under CC BY 4.0.
data "aws_caller_identity" "current" {}

locals {

  account_id = data.aws_caller_identity.current.account_id

}