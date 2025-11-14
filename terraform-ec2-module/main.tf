# © [2025] EDT&Partners. Licensed under CC BY 4.0.
data "aws_ami" "latest_ami" {
  most_recent = true
  owners      = ["amazon"] # Replace with your AMI owner if needed

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "tls_private_key" "ec2_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ec2_key" {
  key_name   = var.key_name
  public_key = tls_private_key.ec2_key.public_key_openssh
}

resource "local_file" "private_key" {
  filename        = "${path.module}/${var.key_name}.pem"
  content         = tls_private_key.ec2_key.private_key_pem
  file_permission = "0600"
}

resource "aws_ssm_parameter" "private_key" {
  name        = "/ec2/${var.key_name}/private_key"
  description = "Base64-encoded private key for EC2 access"
  type        = "SecureString"
  value       = base64encode(tls_private_key.ec2_key.private_key_pem)
  tier        = "Advanced" # Upgrade to Advanced tier to allow larger values

  tags = {
    Name = var.key_name
  }
}



# Create IAM Role for EC2 Instance
resource "aws_iam_role" "ec2_role" {
  name = "${var.instance_name}-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# IAM Policy to Allow Access to Lambda, Bedrock, DynamoDB, Step Functions, and CloudWatch Logs
resource "aws_iam_policy" "ec2_policy" {
  name        = "${var.instance_name}-policy"
  description = "Policy for EC2 to access AWS services"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "lambda:InvokeFunction",
        "lambda:GetFunction"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "bedrock:InvokeModel",
        "bedrock:GetModel"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:UpdateItem",
        "dynamodb:Scan",
        "dynamodb:Query",
        "dynamodb:BatchGetItem",
        "dynamodb:BatchWriteItem"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "states:StartExecution",
        "states:DescribeExecution",
        "states:StopExecution",
        "states:GetExecutionHistory"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogStreams",
        "logs:DescribeLogGroups"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

# Attach policy to the IAM role
resource "aws_iam_role_policy_attachment" "ec2_attach_policy" {
  policy_arn = aws_iam_policy.ec2_policy.arn
  role       = aws_iam_role.ec2_role.name
}

# Create an IAM Instance Profile
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "${var.instance_name}-instance-profile"
  role = aws_iam_role.ec2_role.name
}



resource "aws_instance" "ec2_host" {
  ami                         = data.aws_ami.latest_ami.id
  instance_type               = var.instance_type
  subnet_id                   = var.public_subnet_id
  associate_public_ip_address = true
  key_name                    = aws_key_pair.ec2_key.key_name

  vpc_security_group_ids = [var.security_group_id]

  tags = {
    Name = var.instance_name
  }
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name
}