# © [2025] EDT&Partners. Licensed under CC BY 4.0.
resource "aws_bedrockagent_agent" "this" {
  agent_name              = var.agent_name
  foundation_model        = var.foundation_model
  instruction             = file("${path.module}/instructions/${var.agent_name}.txt")
  agent_resource_role_arn = var.agent_role
  # memory_configuration	  {
  #	storage_days=365
  #	enabled_memory_types="SESSION_SUMMARY"
  # }
}

locals {
  sorted_keys = sort(keys(var.action_groups))
  previous_key_map = {
    for i, key in local.sorted_keys :
    key => i == 0 ? null : local.sorted_keys[i - 1]
  }
}


resource "aws_bedrockagent_agent_action_group" "ag" {
  for_each = var.action_groups

  agent_id                   = aws_bedrockagent_agent.this.id
  agent_version              = "DRAFT"
  action_group_name          = each.key
  description                = "Action group ${each.key} for agent ${var.agent_name}"
  action_group_state         = "ENABLED"
  prepare_agent              = false
  skip_resource_in_use_check = true
  function_schema {
    member_functions {
      dynamic "functions" {
        for_each = flatten([
          for file_name in each.value.files : jsondecode(file("${path.module}/action_group_files/${var.agent_name}/${each.key}/${file_name}"))
        ])

        content {
          name        = functions.value.name
          description = functions.value.description

          dynamic "parameters" {
            for_each = functions.value.parameters

            content {
              map_block_key = parameters.value.name
              type          = parameters.value.type
              description   = parameters.value.description
              required      = parameters.value.required
            }
          }
        }
      }
    }
  }

  dynamic "action_group_executor" {
    for_each = length([
      for val in [each.value] : val
      if lookup(val, "lambda_executor_arn", null) != null || lookup(val, "custom_control", null) != null
    ]) > 0 ? [each.value] : []

    content {
      # If lambda_executor_arn is set, use lambda attribute
      lambda = lookup(action_group_executor.value, "lambda_executor_arn", null)

      # If no lambda_executor_arn, but custom_control exists, use that
      custom_control = lookup(action_group_executor.value, "lambda_executor_arn", null) == null ? lookup(action_group_executor.value, "custom_control", null) : null
    }
  }
}

#resource "null_resource" "wait_for_agent_ready" {
#  provisioner "local-exec" {
#    command = "sleep 60"
#  }
#
#  depends_on = [
#    aws_bedrockagent_agent.this
#  ]
#}

resource "aws_bedrockagent_agent_alias" "this" {
  agent_alias_name = "latest"
  agent_id         = aws_bedrockagent_agent.this.id
  description      = "Latest Version"
}

module "ssm_dynamic_variables" {
  source               = "cloudposse/ssm-parameter-store/aws"
  ignore_value_changes = true
  parameter_write = [
    {
      name        = "/lecture/global/BEDROCK_${upper(replace(var.agent_name, "-", "_"))}"
      value       = aws_bedrockagent_agent.this.id
      type        = "String"
      overwrite   = true
      description = "Bedrock Agent ID ${var.agent_name}"
    }
  ]
}
