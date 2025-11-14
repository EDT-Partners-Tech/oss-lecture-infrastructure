# © [2025] EDT&Partners. Licensed under CC BY 4.0.
resource "aws_iam_role" "stepfunction_role" {
  name = "StepFunctions_IAM_ROLE_${var.name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "states.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "lambda_invoke" {
  name = "LambdaInvokePolicy_${var.name}"
  role = aws_iam_role.stepfunction_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["lambda:InvokeFunction"]
        Resource = ["*"]
      }
    ]
  })
}

resource "aws_sfn_state_machine" "this" {
  name     = var.name
  role_arn = aws_iam_role.stepfunction_role.arn
  type     = "STANDARD"

  definition = templatefile("${path.module}/${var.name}.json", {
    lambda_arns = var.lambda_arns
    description = var.description
  })
}
