<!-- © [2025] EDT&Partners. Licensed under CC BY 4.0. -->
# Lecture Infrastructure

A comprehensive Terraform-based Infrastructure as Code (IaC) solution for managing multi-tenant lecture and educational platform infrastructure on AWS.

## 🏗️ Architecture Overview

This repository contains modular Terraform configurations that deploy a complete AWS infrastructure stack including:

- **Compute**: ECS clusters, Lambda functions, and EC2 instances
- **Storage**: S3 buckets, RDS PostgreSQL clusters
- **Networking**: VPC with public/private subnets, CloudFront CDN
- **Security**: Cognito identity pools, IAM roles, security groups
- **AI/ML**: Amazon Bedrock agents for intelligent content processing
- **Data**: Athena for analytics, DynamoDB for NoSQL storage
- **Integration**: AppSync GraphQL APIs, Step Functions state machines

## 🎯 Supported Customers

The infrastructure supports multiple customer environments:

- **DHBW** (Duale Hochschule Baden-Württemberg)
- **EDT** (Educational Technology)
- **EDT UFV** (Universidad Francisco de Vitoria)
- **Educaria** 
- **GVA** (Generalitat Valenciana)
- **Santillana**
- **UFV** (Universidad Francisco de Vitoria)
- **Unilux**
- **Test Environment**

## 📁 Repository Structure

```
.
├── docs/                           # Documentation
│   ├── architecture/              # Architecture diagrams and decisions
│   ├── deployment/                # Deployment guides
│   ├── development/               # Development standards
│   ├── modules/                   # Module documentation
│   ├── operations/                # Operational runbooks
│   └── security/                  # Security procedures
├── terraform-*-module/            # Reusable Terraform modules
├── *.tf                           # Root Terraform configuration
├── lecture-*-prod-*.tfvars        # Customer-specific variables
├── lecture-*-prod-*.hcl           # Backend configurations
└── scripts.sh                     # Deployment helper scripts
```

## 🚀 Quick Start

### Prerequisites

- Terraform >= 1.12.0
- AWS CLI configured with appropriate credentials
- Access to customer-specific AWS accounts

### Deployment

1. **Select Customer Environment**:
   ```bash
   export CUSTOMER="your-customer"  # e.g., dhbw, edt, unilux
   export AWS_PROFILE="lecture-$CUSTOMER-prod"
   ```

2. **Initialize and Deploy**:
   ```bash
   terraform init -backend-config="$AWS_PROFILE-backend.hcl" -reconfigure
   terraform plan -var-file="$AWS_PROFILE-variables.tfvars"
   terraform apply -var-file="$AWS_PROFILE-variables.tfvars"
   ```

## 🔧 Terraform Modules

| Module | Description | Resources |
|--------|-------------|-----------|
| `terraform-appsync-module` | GraphQL API management | AppSync, API Keys |
| `terraform-athena-module` | Data analytics | Athena, S3 query results |
| `terraform-bedrock-module` | AI/ML agents | Bedrock agents, knowledge bases |
| `terraform-cloudfront-module` | CDN distribution | CloudFront, origins |
| `terraform-cognito-module` | Authentication | User pools, identity pools |
| `terraform-dynamodb-module` | NoSQL database | DynamoDB tables |
| `terraform-ecs-*-module` | Container orchestration | ECS clusters, services, ALB |
| `terraform-lambda-module` | Serverless functions | Lambda functions, layers |
| `terraform-rds-cluster` | Relational database | RDS PostgreSQL cluster |
| `terraform-s3-module` | Object storage | S3 buckets, policies |
| `terraform-secrets-manager-module` | Secret management | Secrets Manager |
| `terraform-security-groups-module` | Network security | Security groups |

## 🔐 Security Features

- **Encryption**: All data encrypted at rest and in transit
- **IAM**: Least privilege access with role-based permissions
- **Secrets Management**: AWS Secrets Manager integration
- **Network Security**: VPC isolation with security groups
- **Compliance**: Checkov security scanning in CI/CD

## 🌍 Multi-Environment Support

Each customer has dedicated:
- AWS account isolation
- Environment-specific variables (`lecture-{customer}-prod-variables.tfvars`)
- Backend state isolation (`lecture-{customer}-prod-backend.hcl`)
- Resource naming conventions

## 📊 Monitoring & Observability

- **CloudWatch**: Centralized logging and metrics
- **VPC Flow Logs**: Network traffic monitoring
- **CloudTrail**: API audit logging
- **Custom Metrics**: Application-specific monitoring

## 🤝 Contributing

Please see [CONTRIBUTING.md](docs/development/CONTRIBUTING.md) for development guidelines, coding standards, and contribution process.

## 📚 Documentation

- [Deployment Guide](docs/deployment/README.md)
- [Architecture Decisions](docs/architecture/ADRs/)
- [Operations Runbook](docs/operations/runbook.md)
- [Security Procedures](docs/security/procedures.md)
- [Module Documentation](docs/modules/)

## 🆘 Support

For operational issues, see the [Operations Runbook](docs/operations/runbook.md) or contact the infrastructure team.

## 📄 License

This infrastructure code is free to use under the [Creative Commons 4.0 license](License.txt)

---

**Infrastructure Version**: 2.0  
**Last Updated**: 2025-08-22  
**Maintained By**: Infrastructure Team# oss-lecture-infrastructure
