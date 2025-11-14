# © [2025] EDT&Partners. Licensed under CC BY 4.0.
variable "name" {
  type = string
}

variable "description" {
  type = string
}
variable "aws_region" {
  type = string
}

variable "lambda_arns" {
  type = object({
    create_collection  = string
    create_index       = string
    create_kb          = string
    create_data_source = string
  })
  default = {
    create_collection  = ""
    create_index       = ""
    create_kb          = ""
    create_data_source = ""
  }
}