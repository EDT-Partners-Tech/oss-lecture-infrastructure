<!-- 
  Copyright 2025 EDT&Partners

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
-->

# Terraform Coding Standards

This document defines the coding standards, style guidelines, and best practices for Terraform code in the Lecture Infrastructure project.

## 📋 Table of Contents

- [File Organization](#file-organization)
- [Naming Conventions](#naming-conventions)
- [Code Formatting](#code-formatting)
- [Variable Standards](#variable-standards)
- [Resource Standards](#resource-standards)
- [Module Standards](#module-standards)
- [Security Standards](#security-standards)
- [Documentation Standards](#documentation-standards)

## 📁 File Organization

### Standard Module Structure

Every Terraform module must follow this structure:

```
terraform-module-name/
├── README.md              # Module documentation
├── main.tf                # Primary resources
├── variables.tf           # Input variables
├── outputs.tf            # Output values
├── locals.tf             # Local values (optional)
├── data.tf               # Data sources (optional)
├── versions.tf           # Provider version constraints
├── examples/             # Usage examples
│   ├── basic/
│   └── advanced/
└── .terraform-docs.yml   # terraform-docs configuration
```

### File Naming Rules

- Use **lowercase** with **hyphens** for directories
- Use **lowercase** with **underscores** for `.tf` files
- Be **descriptive** and **consistent**

```bash
# ✅ Good
terraform-s3-module/
├── main.tf
├── variables.tf
├── bucket_policy.tf
├── lifecycle_rules.tf

# ❌ Bad
Terraform-S3-Module/
├── Main.tf
├── vars.tf
├── bucketPolicy.tf
```

### Resource Organization

Organize resources logically within files:

```hcl
# main.tf - Primary resources
resource "aws_s3_bucket" "main" { ... }
resource "aws_s3_bucket_encryption" "main" { ... }

# iam.tf - IAM-related resources
resource "aws_iam_role" "s3_access" { ... }
resource "aws_iam_policy" "s3_policy" { ... }

# monitoring.tf - Monitoring resources
resource "aws_cloudwatch_metric_alarm" "bucket_requests" { ... }
```

## 🏷️ Naming Conventions

### Resource Names

Use **snake_case** with descriptive names:

```hcl
# ✅ Good
resource "aws_s3_bucket" "content_storage" {
  bucket = "${var.project}-${var.environment}-content"
}

resource "aws_iam_role" "ecs_task_execution" {
  name = "${var.project}-${var.environment}-ecs-execution"
}

# ❌ Bad
resource "aws_s3_bucket" "bucket1" {
  bucket = "mybucket"
}

resource "aws_iam_role" "role" {
  name = "ECSRole"
}
```

### Variable Names

Use **snake_case** with clear, descriptive names:

```hcl
# ✅ Good
variable "backup_retention_period" {
  description = "Number of days to retain automated backups"
  type        = number
  default     = 7
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection for critical resources"
  type        = bool
  default     = true
}

# ❌ Bad
variable "period" {
  type = number
}

variable "enableDP" {
  type = bool
}
```

### Output Names

Use **snake_case** matching the resource attribute:

```hcl
# ✅ Good
output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.content_storage.arn
}

output "database_endpoint" {
  description = "RDS cluster endpoint"
  value       = aws_rds_cluster.main.endpoint
}

# ❌ Bad
output "arn" {
  value = aws_s3_bucket.content_storage.arn
}

output "db" {
  value = aws_rds_cluster.main.endpoint
}
```

### AWS Resource Names

Follow consistent patterns for AWS resource names:

```hcl
# Pattern: {project}-{environment}-{component}[-{purpose}]

# Examples
bucket_name = "lecture-prod-content"
role_name   = "lecture-prod-ecs-execution"
cluster_id  = "lecture-prod-database"
```

## 🎨 Code Formatting

### Indentation and Spacing

- Use **2 spaces** for indentation (no tabs)
- Add **blank lines** between logical blocks
- Align **equals signs** for readability

```hcl
# ✅ Good
resource "aws_s3_bucket" "content_storage" {
  bucket = var.bucket_name
  
  tags = {
    Name        = var.bucket_name
    Environment = var.environment
    Project     = var.project
    Purpose     = "Content storage"
  }
}

# ❌ Bad
resource "aws_s3_bucket" "content_storage" {
bucket = var.bucket_name
tags = {
Name = var.bucket_name
Environment = var.environment
Project = var.project
Purpose = "Content storage"
}
}
```

### Line Length

- Maximum **120 characters** per line
- Break long lines logically

```hcl
# ✅ Good
resource "aws_iam_policy_document" "s3_access" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    resources = [
      "${aws_s3_bucket.content_storage.arn}/*"
    ]
  }
}

# ❌ Bad
resource "aws_iam_policy_document" "s3_access" {
  statement {
    effect = "Allow"
    actions = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = ["${aws_s3_bucket.content_storage.arn}/*"]
  }
}
```

### Comments

Use comments to explain **why**, not **what**:

```hcl
# ✅ Good - Explains reasoning
# Enable versioning to prevent accidental data loss
# and support compliance requirements
resource "aws_s3_bucket_versioning" "content_storage" {
  bucket = aws_s3_bucket.content_storage.id
  versioning_configuration {
    status = "Enabled"
  }
}

# ❌ Bad - States the obvious
# Create S3 bucket versioning
resource "aws_s3_bucket_versioning" "content_storage" { ... }
```

## 📊 Variable Standards

### Variable Declaration

Every variable must include:

```hcl
variable "database_instance_class" {
  description = "Database instance class for RDS cluster"
  type        = string
  default     = "db.t3.medium"
  
  validation {
    condition = contains([
      "db.t3.micro", "db.t3.small", "db.t3.medium",
      "db.t3.large", "db.r5.large", "db.r5.xlarge"
    ], var.database_instance_class)
    error_message = "Database instance class must be a valid RDS instance type."
  }
}
```

### Variable Types

Use specific types for better validation:

```hcl
# ✅ Good - Specific types
variable "security_group_rules" {
  description = "List of security group rules"
  type = list(object({
    type        = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = []
}

# ❌ Bad - Generic types
variable "sg_rules" {
  type = list(any)
}
```

### Variable Validation

Add validation for critical variables:

```hcl
variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  
  validation {
    condition = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "backup_retention_period" {
  description = "Database backup retention period in days"
  type        = number
  default     = 7
  
  validation {
    condition     = var.backup_retention_period >= 1 && var.backup_retention_period <= 35
    error_message = "Backup retention period must be between 1 and 35 days."
  }
}
```

## 🏗️ Resource Standards

### Resource Declaration

Resources should be well-structured and documented:

```hcl
# ✅ Good
resource "aws_rds_cluster" "main" {
  cluster_identifier              = "${var.project}-${var.environment}-cluster"
  engine                         = "aurora-postgresql"
  engine_version                 = var.postgres_version
  database_name                  = var.database_name
  master_username                = var.master_username
  manage_master_user_password    = true
  
  # Network configuration
  vpc_security_group_ids = [aws_security_group.database.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name
  
  # Backup configuration
  backup_retention_period = var.backup_retention_period
  preferred_backup_window = "03:00-04:00"
  
  # Monitoring and logging
  enabled_cloudwatch_logs_exports = ["postgresql"]
  monitoring_interval            = 60
  monitoring_role_arn           = aws_iam_role.rds_monitoring.arn
  
  # Security
  storage_encrypted = true
  kms_key_id       = aws_kms_key.database.arn
  
  # Maintenance
  preferred_maintenance_window = "sun:04:00-sun:05:00"
  
  # Deletion protection for production
  deletion_protection = var.environment == "prod"
  
  tags = merge(var.common_tags, {
    Name = "${var.project}-${var.environment}-database"
    Type = "Database"
  })
}
```

### Conditional Resources

Use `count` or `for_each` for conditional resources:

```hcl
# ✅ Good - Using count for conditional resources
resource "aws_cloudwatch_metric_alarm" "database_cpu" {
  count = var.enable_monitoring ? 1 : 0
  
  alarm_name          = "${var.project}-${var.environment}-db-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"
  
  dimensions = {
    DBClusterIdentifier = aws_rds_cluster.main.cluster_identifier
  }
  
  alarm_actions = var.sns_topic_arn != "" ? [var.sns_topic_arn] : []
}

# ✅ Good - Using for_each for multiple similar resources
resource "aws_s3_bucket" "storage" {
  for_each = var.s3_buckets
  
  bucket = "${var.project}-${var.environment}-${each.key}"
  
  tags = merge(var.common_tags, {
    Name    = "${var.project}-${var.environment}-${each.key}"
    Purpose = each.value.purpose
  })
}
```

### Resource Dependencies

Use explicit dependencies when needed:

```hcl
resource "aws_security_group_rule" "database_ingress" {
  type                     = "ingress"
  from_port               = 5432
  to_port                 = 5432
  protocol                = "tcp"
  source_security_group_id = aws_security_group.application.id
  security_group_id       = aws_security_group.database.id
  
  # Explicit dependency to ensure proper creation order
  depends_on = [
    aws_security_group.database,
    aws_security_group.application
  ]
}
```

## 📦 Module Standards

### Module Interface

Every module should have a clear interface:

```hcl
# variables.tf - Input interface
variable "project" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

# outputs.tf - Output interface
output "bucket_arn" {
  description = "ARN of the created S3 bucket"
  value       = aws_s3_bucket.main.arn
}

output "bucket_id" {
  description = "ID of the created S3 bucket"
  value       = aws_s3_bucket.main.id
}
```

### Module Composition

Use modules to avoid code duplication:

```hcl
# ✅ Good - Using modules
module "content_bucket" {
  source = "./modules/s3-bucket"
  
  project     = var.project
  environment = var.environment
  bucket_name = "content"
  purpose     = "Content storage"
  
  enable_versioning = true
  enable_encryption = true
  
  tags = var.common_tags
}

module "backup_bucket" {
  source = "./modules/s3-bucket"
  
  project     = var.project
  environment = var.environment
  bucket_name = "backup"
  purpose     = "Backup storage"
  
  enable_versioning = true
  enable_encryption = true
  lifecycle_rules   = var.backup_lifecycle_rules
  
  tags = var.common_tags
}
```

### Module Versioning

Use version constraints for external modules:

```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"
  
  name = "${var.project}-${var.environment}-vpc"
  cidr = var.vpc_cidr
  
  azs             = data.aws_availability_zones.available.names
  private_subnets = var.private_subnet_cidrs
  public_subnets  = var.public_subnet_cidrs
  
  enable_nat_gateway = true
  enable_vpn_gateway = false
  
  tags = var.common_tags
}
```

## 🔐 Security Standards

### Secret Management

Never hardcode secrets:

```hcl
# ✅ Good - Using AWS Secrets Manager
resource "aws_db_instance" "main" {
  identifier = "${var.project}-${var.environment}-db"
  
  # Use managed master user password
  manage_master_user_password = true
  master_username            = "postgres"
  
  # Other configuration...
}

# ❌ Bad - Hardcoded password
resource "aws_db_instance" "main" {
  identifier = "${var.project}-${var.environment}-db"
  
  master_username = "postgres"
  master_password = "hardcoded-password"  # NEVER DO THIS
}
```

### IAM Policies

Follow least privilege principle:

```hcl
# ✅ Good - Specific permissions
data "aws_iam_policy_document" "s3_access" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]
    resources = [
      "${aws_s3_bucket.content.arn}/uploads/*"
    ]
  }
  
  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket"
    ]
    resources = [
      aws_s3_bucket.content.arn
    ]
    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values   = ["uploads/*"]
    }
  }
}

# ❌ Bad - Overly broad permissions
data "aws_iam_policy_document" "s3_access" {
  statement {
    effect    = "Allow"
    actions   = ["s3:*"]
    resources = ["*"]
  }
}
```

### Encryption

Enable encryption by default:

```hcl
# ✅ Good
resource "aws_s3_bucket" "content" {
  bucket = "${var.project}-${var.environment}-content"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "content" {
  bucket = aws_s3_bucket.content.id
  
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3.arn
    }
    bucket_key_enabled = true
  }
}
```

## 📚 Documentation Standards

### Resource Documentation

Document complex resources:

```hcl
# Lambda function for processing uploaded content
# Triggered by S3 events and processes files asynchronously
# Stores results in DynamoDB and sends notifications via SNS
resource "aws_lambda_function" "content_processor" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "${var.project}-${var.environment}-content-processor"
  role            = aws_iam_role.lambda_execution.arn
  handler         = "index.handler"
  runtime         = "python3.9"
  timeout         = 300
  memory_size     = 512
  
  # Environment variables for configuration
  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.content.name
      SNS_TOPIC_ARN  = aws_sns_topic.notifications.arn
      S3_BUCKET      = aws_s3_bucket.content.bucket
    }
  }
  
  tags = merge(var.common_tags, {
    Name    = "${var.project}-${var.environment}-content-processor"
    Purpose = "Content processing and notification"
  })
}
```

### Module Documentation

Include comprehensive README.md:

```markdown
# S3 Bucket Module

This module creates an S3 bucket with security best practices enabled by default.

## Features

- Server-side encryption with KMS
- Versioning enabled
- Public access blocked
- Lifecycle rules support
- CloudWatch monitoring

## Usage

```hcl
module "content_bucket" {
  source = "./modules/s3-bucket"
  
  project     = "myproject"
  environment = "prod"
  bucket_name = "content"
  
  enable_versioning = true
  lifecycle_rules   = var.lifecycle_rules
}
```
```

## 🛠️ Tools and Automation

### Required Tools

- **terraform fmt**: Format code consistently
- **terraform validate**: Validate syntax and configuration
- **tflint**: Advanced linting for Terraform
- **checkov**: Security and compliance scanning
- **terraform-docs**: Generate documentation

### Pre-commit Hooks

```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/antonbabenko/pre-commit-terraform
    rev: v1.77.0
    hooks:
      - id: terraform_fmt
      - id: terraform_validate
      - id: terraform_docs
      - id: terraform_tflint
      - id: checkov
```

### VS Code Configuration

```json
{
  "terraform.format.enable": true,
  "terraform.validate.enable": true,
  "editor.formatOnSave": true,
  "editor.tabSize": 2,
  "editor.insertSpaces": true
}
```

## 📋 Code Review Checklist

Before submitting code:

- [ ] **Formatting**: Code is properly formatted (`terraform fmt`)
- [ ] **Validation**: Code passes validation (`terraform validate`)
- [ ] **Linting**: No linting errors (`tflint`)
- [ ] **Security**: No security issues (`checkov`)
- [ ] **Documentation**: All variables and outputs documented
- [ ] **Examples**: Usage examples provided
- [ ] **Testing**: Tested in development environment
- [ ] **Naming**: Consistent naming conventions followed
- [ ] **Structure**: Proper file organization
- [ ] **Dependencies**: Appropriate version constraints

---

**Last Updated**: 2025-08-22  
**Version**: 2.0  
**Maintained By**: Infrastructure Team