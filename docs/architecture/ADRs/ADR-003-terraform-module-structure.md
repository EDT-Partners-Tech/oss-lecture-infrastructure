<!-- © [2025] EDT&Partners. Licensed under CC BY 4.0. -->
# ADR-003: Terraform Module Structure

## Status
Accepted

## Context

The Lecture Infrastructure needs a consistent, maintainable, and scalable Infrastructure as Code (IaC) approach. With multiple customers requiring similar but customizable infrastructure, we need a module structure that:

- Promotes code reusability across customer environments
- Maintains consistency while allowing customization
- Enables easy testing and validation
- Supports rapid deployment of new customer environments
- Facilitates maintenance and updates across all customers

Current challenges:
- Need to deploy similar infrastructure for 9+ customers
- Each customer has specific configuration requirements
- Manual deployments are error-prone and time-consuming
- Inconsistencies between customer environments

## Decision

We will implement a **modular Terraform architecture** with the following structure:

### 1. Module Organization Pattern
```
terraform-{service}-module/
├── README.md              # Module documentation
├── main.tf                # Primary resources
├── variables.tf           # Input variables with validation
├── outputs.tf            # Output values with descriptions
├── locals.tf             # Local calculations (optional)
├── data.tf               # Data sources (optional)
├── versions.tf           # Provider version constraints
└── examples/             # Usage examples
    ├── basic/
    └── advanced/
```

### 2. Root Configuration Structure
```
.
├── terraform-*-module/    # Reusable modules
├── *.tf                  # Root configuration files
├── lecture-*-prod-*.tfvars # Customer-specific variables
├── lecture-*-prod-*.hcl   # Backend configurations
└── scripts.sh            # Deployment automation
```

### 3. Naming Conventions
- **Modules**: `terraform-{service}-module` (e.g., `terraform-s3-module`)
- **Resources**: `{service}_{purpose}` (e.g., `s3_content_bucket`)
- **Variables**: `snake_case` with descriptive names
- **Outputs**: Match resource attributes when possible

### 4. Module Composition Strategy
- **Single Responsibility**: Each module manages one logical service
- **Composable**: Modules can be combined to create complex architectures
- **Configurable**: Extensive variable support for customization
- **Validated**: Input validation for critical parameters

## Consequences

### Positive

- **Code Reusability**: Write once, deploy multiple times across customers
- **Consistency**: Standardized infrastructure patterns across all environments
- **Maintainability**: Centralized module updates benefit all customers
- **Testability**: Modules can be tested independently
- **Documentation**: Self-documenting through terraform-docs
- **Deployment Speed**: Rapid deployment of new customer environments
- **Best Practices**: Enforced security and operational best practices

### Negative

- **Initial Complexity**: Higher upfront investment in module design
- **Abstraction Overhead**: Additional layer between resources and implementation
- **Learning Curve**: Team needs to understand module patterns
- **Version Management**: Need to manage module versions and dependencies
- **Testing Complexity**: Requires comprehensive testing strategy

### Neutral

- **Module Evolution**: Modules will evolve over time with new requirements
- **Customization Limits**: Some customer-specific needs may not fit module patterns
- **Terraform Constraints**: Limited by Terraform language capabilities

## Alternatives Considered

### 1. Monolithic Terraform Configuration
**Pros**: Simple to understand, direct resource management
**Cons**: Code duplication, inconsistency, difficult to maintain
**Rejected**: Doesn't scale with multiple customers

### 2. Copy-Paste Per Customer
**Pros**: Complete customization per customer, no abstraction
**Cons**: Massive maintenance burden, inconsistency, error-prone
**Rejected**: Unsustainable for multiple customers

### 3. External Module Registry
**Pros**: Leverage community modules, faster development
**Cons**: External dependencies, less control, security concerns
**Rejected**: Need custom modules for specific requirements

### 4. Ansible or Other Tools
**Pros**: Different approach, potentially simpler for some tasks
**Cons**: Team expertise is in Terraform, context switching overhead
**Rejected**: Leverage existing Terraform expertise

## Implementation Guidelines

### Module Design Principles

#### 1. Variable Design
```hcl
variable "backup_retention_period" {
  description = "Number of days to retain automated backups"
  type        = number
  default     = 7
  
  validation {
    condition     = var.backup_retention_period >= 1 && var.backup_retention_period <= 35
    error_message = "Backup retention period must be between 1 and 35 days."
  }
}
```

#### 2. Output Design
```hcl
output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.main.arn
}

output "bucket_id" {
  description = "ID of the S3 bucket"  
  value       = aws_s3_bucket.main.id
}
```

#### 3. Resource Naming
```hcl
resource "aws_s3_bucket" "content_storage" {
  bucket = "${var.project}-${var.environment}-content"
  
  tags = merge(var.common_tags, {
    Name    = "${var.project}-${var.environment}-content"
    Purpose = "Content storage"
  })
}
```

### Module Testing Strategy

#### 1. Validation Testing
```hcl
# In variables.tf
variable "environment" {
  description = "Environment name"
  type        = string
  
  validation {
    condition = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}
```

#### 2. Example Configurations
```hcl
# In examples/basic/main.tf
module "s3_bucket" {
  source = "../../"
  
  project     = "test"
  environment = "dev"
  bucket_name = "example"
  
  enable_versioning = true
  enable_encryption = true
}
```

### Customer Configuration Pattern

#### 1. Customer-Specific Variables
```hcl
# lecture-dhbw-prod-variables.tfvars
aws_region           = "eu-central-1"
vpc_range           = "10.2.0.0/16"
backup_retention    = 30
enable_monitoring   = true
```

#### 2. Module Usage in Root
```hcl
module "content_bucket" {
  source = "./terraform-s3-module"
  
  project     = var.project
  environment = var.environment
  bucket_name = "content"
  
  enable_versioning = true
  enable_encryption = true
  lifecycle_rules   = local.content_lifecycle_rules
  
  tags = local.common_tags
}
```

## Module Inventory

### Current Modules (23 total)

#### Core Infrastructure
- `terraform-security-groups-module`: Network security management
- `terraform-iam-module`: Identity and access management
- `terraform-tags-module`: Standardized resource tagging

#### Compute and Containers
- `terraform-ec2-module`: Virtual machine management
- `terraform-ecs-cluster-module`: Container cluster orchestration
- `terraform-ecs-service-module`: Container service management
- `terraform-lambda-module`: Serverless function management

#### Storage and Databases
- `terraform-s3-module`: Object storage management
- `terraform-rds-cluster`: Relational database clustering
- `terraform-dynamodb-module`: NoSQL database management

#### Networking and CDN
- `terraform-cloudfront-module`: Content delivery network
- `terraform-r53-module`: DNS management

#### Security and Authentication
- `terraform-cognito-module`: User authentication
- `terraform-secrets-manager-module`: Secret management
- `terraform-identity-provider-module`: GitHub OIDC integration

#### AI/ML and Analytics
- `terraform-bedrock-module`: AI/ML service integration
- `terraform-athena-module`: Data analytics
- `terraform-appsync-module`: GraphQL API management

#### Orchestration and Integration
- `terraform-state-machine-module`: Workflow orchestration
- `terraform-lambda-layer-module`: Shared function dependencies

#### DevOps and Automation
- `terraform-ecr-module`: Container registry management
- `terraform-ecs-alb-module`: Load balancer for containers
- `terraform-ec2-alb-module`: Load balancer for virtual machines

## Versioning Strategy

### Module Versioning
- Use semantic versioning (MAJOR.MINOR.PATCH)
- Tag releases in Git for stable versions
- Document breaking changes in module README
- Maintain backward compatibility when possible

### Dependency Management
```hcl
# versions.tf in each module
terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```

## Migration and Adoption

### Phase 1: Core Modules (Completed)
- [x] Create foundational modules (S3, RDS, ECS)
- [x] Standardize variable and output patterns
- [x] Implement basic validation

### Phase 2: Advanced Modules (Completed)
- [x] AI/ML integration modules
- [x] Advanced networking modules
- [x] Security and compliance modules

### Phase 3: Optimization and Enhancement
- [ ] Advanced testing framework
- [ ] Automated module documentation
- [ ] Performance optimization
- [ ] Cost optimization features

## Success Metrics

- **Deployment Time**: New customer deployment in < 4 hours
- **Consistency**: 100% compliance with infrastructure standards
- **Maintenance Efficiency**: Module updates applied to all customers in < 2 hours
- **Error Rate**: < 1% deployment failures due to module issues
- **Developer Productivity**: 75% reduction in infrastructure code duplication

## Related ADRs

- ADR-001: Multi-Tenant Architecture Design
- ADR-002: AWS Services Selection
- ADR-006: Security Architecture Framework

---

**Decision Date**: 2025-08-22  
**Decision Makers**: Architecture Team, DevOps Lead  
**Stakeholders**: Development Team, Operations Team