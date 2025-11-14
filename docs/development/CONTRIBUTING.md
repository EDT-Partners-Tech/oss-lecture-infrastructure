<!-- © [2025] EDT&Partners. Licensed under CC BY 4.0. -->
# Contributing to Lecture Infrastructure

Thank you for your interest in contributing to the Lecture Infrastructure project! This document provides guidelines and standards for development, testing, and contributing to this Terraform-based infrastructure codebase.

## 📋 Table of Contents

- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Coding Standards](#coding-standards)
- [Testing Requirements](#testing-requirements)
- [Pull Request Process](#pull-request-process)
- [Security Guidelines](#security-guidelines)
- [Documentation Standards](#documentation-standards)

## 🚀 Getting Started

### Prerequisites

Before contributing, ensure you have:

- **Terraform** >= 1.12.0
- **AWS CLI** v2 with configured access
- **Git** with commit signing enabled
- **Pre-commit hooks** installed
- Access to the development/testing AWS accounts

### Development Environment Setup

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd lecture-infrastructure
   ```

2. **Install pre-commit hooks**:
   ```bash
   # Install pre-commit
   pip install pre-commit
   
   # Install hooks
   pre-commit install
   ```

3. **Configure AWS profiles**:
   ```bash
   # Configure test environment
   aws configure --profile lecture-test-prod
   ```

4. **Verify setup**:
   ```bash
   terraform version
   terraform fmt -check -recursive .
   terraform validate
   ```

## 🔄 Development Workflow

### Branch Strategy

We use **GitFlow** with the following branches:

- `main`: Production-ready code
- `develop`: Integration branch for features
- `feature/*`: New features or enhancements
- `hotfix/*`: Critical production fixes
- `release/*`: Release preparation

### Creating a Feature Branch

```bash
# Start from develop branch
git checkout develop
git pull origin develop

# Create feature branch
git checkout -b feature/your-feature-name

# Make your changes
# ... development work ...

# Commit with conventional commits
git commit -m "feat(module): add new S3 encryption configuration"
```

### Conventional Commits

Use conventional commit format:

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

**Types**:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes
- `refactor`: Code refactoring
- `test`: Test additions/modifications
- `chore`: Build process or auxiliary tool changes

**Examples**:
```bash
git commit -m "feat(s3): add versioning configuration"
git commit -m "fix(ecs): resolve task definition memory allocation"
git commit -m "docs(readme): update deployment instructions"
```

## 📝 Coding Standards

### Terraform Standards

#### File Organization

```
terraform-module-name/
├── main.tf              # Primary resources
├── variables.tf         # Input variables
├── outputs.tf          # Output values
├── locals.tf           # Local values (if needed)
├── data.tf             # Data sources (if needed)
├── versions.tf         # Provider version constraints
└── README.md           # Module documentation
```

#### Naming Conventions

- **Resources**: Use descriptive names with underscores
  ```hcl
  resource "aws_s3_bucket" "content_storage" {
    bucket = "${var.project}-${var.environment}-content"
  }
  ```

- **Variables**: Use snake_case with descriptive names
  ```hcl
  variable "backup_retention_period" {
    description = "Number of days to retain automated backups"
    type        = number
    default     = 7
  }
  ```

- **Outputs**: Use snake_case and include description
  ```hcl
  output "bucket_arn" {
    description = "ARN of the S3 bucket"
    value       = aws_s3_bucket.content_storage.arn
  }
  ```

#### Code Style

- **Indentation**: Use 2 spaces
- **Line length**: Maximum 120 characters
- **Comments**: Use `#` for single-line comments
- **Formatting**: Always run `terraform fmt` before committing

```hcl
# Good example
resource "aws_s3_bucket" "example" {
  bucket = var.bucket_name
  
  tags = {
    Name        = var.bucket_name
    Environment = var.environment
    Project     = var.project
  }
}

# Bad example
resource "aws_s3_bucket" "example" {
bucket = var.bucket_name
tags = {
Name = var.bucket_name
Environment = var.environment
Project = var.project
}
}
```

#### Security Best Practices

- Never hardcode sensitive values
- Use AWS Secrets Manager for secrets
- Enable encryption by default
- Follow least-privilege principles for IAM

```hcl
# Good: Use Secrets Manager
resource "aws_db_instance" "example" {
  manage_master_user_password = true
  # ... other configuration
}

# Bad: Hardcoded password
resource "aws_db_instance" "example" {
  password = "hardcoded-password"  # NEVER DO THIS
}
```

### Variable Documentation

Every variable must include:
- **Description**: Clear explanation of purpose
- **Type**: Proper type constraint
- **Default**: When appropriate
- **Validation**: When needed

```hcl
variable "instance_type" {
  description = "EC2 instance type for the application servers"
  type        = string
  default     = "t3.medium"
  
  validation {
    condition = contains([
      "t3.small", "t3.medium", "t3.large",
      "m5.large", "m5.xlarge"
    ], var.instance_type)
    error_message = "Instance type must be a valid EC2 instance type."
  }
}
```

## 🧪 Testing Requirements

### Pre-commit Checks

All commits must pass:
- `terraform fmt -check -recursive .`
- `terraform validate`
- Security scanning (Checkov)
- Documentation generation

### Module Testing

Each module should include:

1. **Example configurations** in `examples/` directory
2. **Variable validation** where appropriate
3. **Output testing** in test environment

### Integration Testing

Before merging:
1. Deploy to test environment
2. Verify all resources are created correctly
3. Test functionality end-to-end
4. Clean up test resources

```bash
# Test deployment
export CUSTOMER="test"
export AWS_PROFILE="lecture-test-prod"

terraform init -backend-config="lecture-test-prod-backend.hcl"
terraform plan -var-file="lecture-test-prod-variables.tfvars"
terraform apply -var-file="lecture-test-prod-variables.tfvars"

# Verify and cleanup
terraform destroy -var-file="lecture-test-prod-variables.tfvars"
```

## 🔍 Pull Request Process

### PR Requirements

1. **Branch from `develop`** for features
2. **Descriptive title** using conventional commit format
3. **Detailed description** explaining changes
4. **Testing evidence** showing successful deployment
5. **Documentation updates** if needed
6. **Security review** for sensitive changes

### PR Template

```markdown
## Description
Brief description of changes and motivation.

## Type of Change
- [ ] Bug fix (non-breaking change that fixes an issue)
- [ ] New feature (non-breaking change that adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update

## Testing
- [ ] Terraform plan executed successfully
- [ ] Deployed to test environment
- [ ] All resources created/updated as expected
- [ ] No security issues identified
- [ ] Documentation updated

## Checklist
- [ ] Code follows project style guidelines
- [ ] Self-review of code completed
- [ ] Comments added for hard-to-understand areas
- [ ] Documentation updated where necessary
- [ ] No new warnings or errors introduced
```

### Review Process

1. **Automated checks** must pass
2. **Security review** by team lead
3. **Code review** by at least one other developer
4. **Approval** from module owner
5. **Merge** after all requirements met

## 🛡️ Security Guidelines

### Secrets Management

- **Never commit secrets** to version control
- **Use AWS Secrets Manager** for sensitive data
- **Use environment variables** for configuration
- **Rotate secrets regularly**

### Access Control

- **Least privilege**: Grant minimum required permissions
- **Regular reviews**: Audit access permissions quarterly
- **MFA required**: For all administrative access
- **Audit logging**: Enable CloudTrail for all accounts

### Code Security

- **Static analysis**: Use Checkov in CI/CD
- **Dependency scanning**: Monitor for vulnerable dependencies
- **Infrastructure scanning**: Regular security assessments
- **Compliance**: Follow security frameworks (SOC2, ISO27001)

## 📚 Documentation Standards

### Module Documentation

Each module must include:

1. **README.md** with:
   - Purpose and description
   - Usage examples
   - Input variables table
   - Output values table
   - Requirements and dependencies

2. **Auto-generated docs** using `terraform-docs`:
   ```bash
   terraform-docs markdown table . > README.md
   ```

### Architecture Documentation

- **ADRs** for significant decisions
- **Diagrams** for complex architectures
- **Runbooks** for operational procedures
- **Change logs** for version tracking

## 🚫 What Not to Do

### Security Anti-Patterns

- ❌ Hardcode secrets or credentials
- ❌ Use overly permissive IAM policies
- ❌ Disable encryption
- ❌ Ignore security scanning results

### Code Anti-Patterns

- ❌ Copy-paste code without understanding
- ❌ Create overly complex modules
- ❌ Skip variable validation
- ❌ Ignore Terraform best practices

### Process Anti-Patterns

- ❌ Skip testing in development environment
- ❌ Push directly to main branch
- ❌ Ignore PR review feedback
- ❌ Deploy without proper approval

## 📞 Getting Help

### Resources

- **Documentation**: Check the `/docs` directory
- **Examples**: Review existing module examples
- **Team Chat**: Use designated Slack channels
- **Office Hours**: Weekly team sync meetings

### Escalation

For urgent issues:
1. **Team Lead**: Technical questions
2. **Security Team**: Security concerns
3. **DevOps Team**: Infrastructure issues
4. **Product Owner**: Feature requirements

## 🎯 Quality Gates

All contributions must meet:

- [ ] **Code Quality**: Passes all linting and validation
- [ ] **Security**: No high/critical security issues
- [ ] **Testing**: Successful deployment in test environment
- [ ] **Documentation**: Updated and accurate
- [ ] **Review**: Approved by required reviewers

---

**Last Updated**: 2025-08-22  
**Version**: 2.0  
**Contact**: Infrastructure Team