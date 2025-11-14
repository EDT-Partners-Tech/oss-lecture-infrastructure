# © [2025] EDT&Partners. Licensed under CC BY 4.0.
variable "project" {
  description = "Name of the Project"
  type        = string

}
variable "agent_name" {
  description = "Name of the Bedrock agent"
  type        = string
}
variable "agent_role" {
  description = "Name of the Bedrock Role"
  type        = string
}

variable "foundation_model" {
  description = "Foundation model for the agent"
  type        = string
}
variable "action_groups" {
  type = map(object({
    lambda_executor_arn = optional(string)
    custom_control      = optional(string)
    files               = optional(list(string), [])
  }))
}


variable "agent_resource_role_arn" {
  description = "List of action groups for the agent"
  type        = string
}
