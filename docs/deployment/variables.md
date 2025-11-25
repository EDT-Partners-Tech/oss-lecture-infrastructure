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

# Variable Documentation

This document provides comprehensive documentation for all Terraform variables used across customer environments, including examples and validation rules.

## 📋 Table of Contents

- [Global Variables](#global-variables)
- [Customer-Specific Variables](#customer-specific-variables)
- [Environment Examples](#environment-examples)
- [Variable Validation](#variable-validation)
- [Best Practices](#best-practices)

## 🌍 Global Variables

### Core Infrastructure Variables

#### `project`
- **Description**: Project name used for resource naming and tagging
- **Type**: `string`
- **Default**: `"lecture"`
- **Example**: `"lecture"`
- **Used in**: All resource names and tags

#### `environment`
- **Description**: Environment name (prod, staging, dev)
- **Type**: `string`
- **Default**: `"prod"`
- **Valid Values**: `["prod", "staging", "dev"]`
- **Example**: `"prod"`

#### `aws_region`
- **Description**: AWS region for resource deployment
- **Type**: `string`
- **Default**: None (must be specified)
- **Valid Values**: AWS regions where services are available
- **Examples**: 
  - `"eu-central-1"` (Frankfurt)
  - `"us-east-1"` (N. Virginia)

### Network Configuration

#### `vpc_range`
- **Description**: CIDR block for the VPC
- **Type**: `string`
- **Default**: `"10.2.0.0/16"`
- **Format**: Valid CIDR notation
- **Example**: `"10.2.0.0/16"`

#### `vpc_range_public_1a`
- **Description**: CIDR block for public subnet in AZ 1a
- **Type**: `string`
- **Default**: `"10.2.101.0/24"`
- **Example**: `"10.2.101.0/24"`

#### `vpc_range_public_1b`
- **Description**: CIDR block for public subnet in AZ 1b
- **Type**: `string`
- **Default**: `"10.2.102.0/24"`
- **Example**: `"10.2.102.0/24"`

#### `vpc_range_private_1a`
- **Description**: CIDR block for private subnet in AZ 1a
- **Type**: `string`
- **Default**: `"10.2.1.0/24"`
- **Example**: `"10.2.1.0/24"`

#### `vpc_range_private_1b`
- **Description**: CIDR block for private subnet in AZ 1b
- **Type**: `string`
- **Default**: `"10.2.2.0/24"`
- **Example**: `"10.2.2.0/24"`

### Authentication & Security

#### `github_token`
- **Description**: GitHub token for ECR authentication
- **Type**: `string`
- **Default**: `""` (must be provided securely)
- **Security**: Store in GitHub Actions secrets
- **Example**: `"ghp_xxxxxxxxxxxxxxxxxxxx"`

## 🏢 Customer-Specific Variables

### DHBW (Duale Hochschule Baden-Württemberg)

```hcl
# lecture-dhbw-prod-variables.tfvars
aws_region           = "eu-central-1"
github_token        = ""  # Set via GitHub Actions secrets
vpc_range           = "10.2.0.0/16"
vpc_range_public_1a = "10.2.101.0/24"
vpc_range_public_1b = "10.2.102.0/24"
vpc_range_private_1a = "10.2.1.0/24"
vpc_range_private_1b = "10.2.2.0/24"
```

### EDT (Educational Technology)

```hcl
# lecture-edt-prod-variables.tfvars
aws_region           = "us-east-1"
github_token        = ""
vpc_range           = "10.3.0.0/16"
vpc_range_public_1a = "10.3.101.0/24"
vpc_range_public_1b = "10.3.102.0/24"
vpc_range_private_1a = "10.3.1.0/24"
vpc_range_private_1b = "10.3.2.0/24"
```

### Unilux

```hcl
# lecture-unilux-prod-variables.tfvars
aws_region           = "eu-central-1"
github_token        = ""
vpc_range           = "10.4.0.0/16"
vpc_range_public_1a = "10.4.101.0/24"
vpc_range_public_1b = "10.4.102.0/24"
vpc_range_private_1a = "10.4.1.0/24"
vpc_range_private_1b = "10.4.2.0/24"
```

### Test Environment

```hcl
# lecture-test-prod-variables.tfvars
aws_region           = "us-east-1"
github_token        = ""
vpc_range           = "10.1.0.0/16"
vpc_range_public_1a = "10.1.101.0/24"
vpc_range_public_1b = "10.1.102.0/24"
vpc_range_private_1a = "10.1.1.0/24"
vpc_range_private_1b = "10.1.2.0/24"
```

## 📊 Environment Examples

### Development Environment

```hcl
# terraform.tfvars for development
project             = "lecture"
environment         = "dev"
aws_region          = "us-east-1"
vpc_range           = "10.0.0.0/16"
vpc_range_public_1a = "10.0.101.0/24"
vpc_range_public_1b = "10.0.102.0/24"
vpc_range_private_1a = "10.0.1.0/24"
vpc_range_private_1b = "10.0.2.0/24"

# Development-specific overrides
enable_deletion_protection = false
backup_retention_period   = 1
log_retention_days        = 7
instance_type            = "t3.micro"
```

### Staging Environment

```hcl
# terraform.tfvars for staging
project             = "lecture"
environment         = "staging"
aws_region          = "eu-central-1"
vpc_range           = "10.5.0.0/16"
vpc_range_public_1a = "10.5.101.0/24"
vpc_range_public_1b = "10.5.102.0/24"
vpc_range_private_1a = "10.5.1.0/24"
vpc_range_private_1b = "10.5.2.0/24"

# Staging-specific settings
enable_deletion_protection = true
backup_retention_period   = 7
log_retention_days        = 14
instance_type            = "t3.small"
```

### Production Environment

```hcl
# terraform.tfvars for production
project             = "lecture"
environment         = "prod"
aws_region          = "eu-central-1"
vpc_range           = "10.2.0.0/16"
vpc_range_public_1a = "10.2.101.0/24"
vpc_range_public_1b = "10.2.102.0/24"
vpc_range_private_1a = "10.2.1.0/24"
vpc_range_private_1b = "10.2.2.0/24"

# Production-specific settings
enable_deletion_protection = true
backup_retention_period   = 30
log_retention_days        = 90
instance_type            = "t3.medium"
enable_monitoring        = true
enable_multi_az          = true
```

## ✅ Variable Validation

### CIDR Block Validation

```hcl
variable "vpc_range" {
  description = "CIDR block for the VPC"
  type        = string
  
  validation {
    condition = can(cidrhost(var.vpc_range, 0))
    error_message = "VPC range must be a valid CIDR block."
  }
  
  validation {
    condition = split("/", var.vpc_range)[1] >= 16 && split("/", var.vpc_range)[1] <= 28
    error_message = "VPC CIDR block must be between /16 and /28."
  }
}
```

### Region Validation

```hcl
variable "aws_region" {
  description = "AWS region for resource deployment"
  type        = string
  
  validation {
    condition = contains([
      "us-east-1", "us-east-2", "us-west-1", "us-west-2",
      "eu-central-1", "eu-west-1", "eu-west-2", "eu-west-3",
      "ap-southeast-1", "ap-southeast-2", "ap-northeast-1"
    ], var.aws_region)
    error_message = "AWS region must be a supported region."
  }
}
```

### Environment Validation

```hcl
variable "environment" {
  description = "Environment name"
  type        = string
  
  validation {
    condition = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}
```

## 🎯 Advanced Variable Patterns

### Conditional Variables

```hcl
# Enable features based on environment
variable "enable_monitoring" {
  description = "Enable enhanced monitoring"
  type        = bool
  default     = false
}

variable "enable_backup" {
  description = "Enable automated backups"
  type        = bool
  default     = true
}

# Usage in locals
locals {
  monitoring_enabled = var.environment == "prod" ? true : var.enable_monitoring
  backup_enabled     = var.environment != "dev" ? true : var.enable_backup
}
```

### Complex Object Variables

```hcl
variable "database_config" {
  description = "Database configuration settings"
  type = object({
    engine_version        = string
    instance_class       = string
    allocated_storage    = number
    backup_retention     = number
    multi_az            = bool
    storage_encrypted   = bool
  })
  
  default = {
    engine_version      = "13.7"
    instance_class     = "db.t3.medium"
    allocated_storage  = 100
    backup_retention   = 7
    multi_az          = true
    storage_encrypted = true
  }
}
```

### Map Variables for Multi-Environment

```hcl
variable "environment_configs" {
  description = "Environment-specific configurations"
  type = map(object({
    instance_type           = string
    min_capacity           = number
    max_capacity           = number
    backup_retention_period = number
  }))
  
  default = {
    dev = {
      instance_type           = "t3.micro"
      min_capacity           = 1
      max_capacity           = 2
      backup_retention_period = 1
    }
    staging = {
      instance_type           = "t3.small"
      min_capacity           = 1
      max_capacity           = 3
      backup_retention_period = 7
    }
    prod = {
      instance_type           = "t3.medium"
      min_capacity           = 2
      max_capacity           = 10
      backup_retention_period = 30
    }
  }
}
```

## 🔐 Security Considerations

### Sensitive Variables

Never include sensitive values in `.tfvars` files:

```hcl
# ❌ Never do this
database_password = "hardcoded-password"
api_key          = "secret-api-key"

# ✅ Instead, use
database_password = ""  # Set via environment variable
api_key          = ""  # Set via AWS Secrets Manager
```

### Environment Variable Override

```bash
# Set sensitive variables via environment
export TF_VAR_database_password="$(aws secretsmanager get-secret-value --secret-id db-password --query SecretString --output text)"
export TF_VAR_github_token="$(cat ~/.github/token)"

# Run Terraform
terraform apply -var-file="lecture-$CUSTOMER-prod-variables.tfvars"
```

## 📋 Variable Checklist

When adding new variables:

- [ ] **Description**: Clear and comprehensive
- [ ] **Type**: Properly constrained
- [ ] **Default**: Sensible default value if applicable
- [ ] **Validation**: Input validation rules
- [ ] **Examples**: Usage examples provided
- [ ] **Documentation**: Added to this document
- [ ] **Security**: No sensitive defaults
- [ ] **Naming**: Follows snake_case convention

## 🔄 Variable Management Workflow

### Adding New Variables

1. **Define in variables.tf**:
   ```hcl
   variable "new_feature_enabled" {
     description = "Enable the new feature functionality"
     type        = bool
     default     = false
   }
   ```

2. **Add to customer tfvars**:
   ```hcl
   new_feature_enabled = true
   ```

3. **Update documentation**:
   - Add to this document
   - Update module README
   - Include in examples

4. **Test across environments**:
   ```bash
   # Test in development first
   terraform plan -var-file="lecture-test-prod-variables.tfvars"
   ```

### Deprecating Variables

1. **Mark as deprecated** in description
2. **Provide migration path** in documentation
3. **Remove after grace period** (minimum 2 releases)
4. **Update all customer configurations**

## 📞 Support

For variable-related questions:
- Check this documentation first
- Review module-specific variable documentation
- Consult the [Operations Runbook](../operations/runbook.md)
- Contact the infrastructure team

---

**Last Updated**: 2025-08-22  
**Version**: 2.0  
**Maintained By**: Infrastructure Team