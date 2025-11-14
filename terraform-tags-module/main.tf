# © [2025] EDT&Partners. Licensed under CC BY 4.0.
locals {
  local_tags = {
    project     = var.project
    module      = var.module
    environment = var.environment
  }

  tags = merge(
    local.local_tags,
    var.tags
  )
}