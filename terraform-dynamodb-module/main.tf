# © [2025] EDT&Partners. Licensed under CC BY 4.0.
resource "aws_dynamodb_table" "this" {
  name         = var.table_name
  billing_mode = "PAY_PER_REQUEST" # Change to "PROVISIONED" if you want to specify RCU/WCU
  hash_key     = "JobName"         # Primary key attribute
  attribute {
    name = "JobName"
    type = "S" # String type
  }

  tags = var.tags

}
