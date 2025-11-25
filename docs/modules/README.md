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

# Terraform Modules Documentation

This directory contains comprehensive documentation for all Terraform modules used in the Lecture Infrastructure project.

## 📋 Module Index

| Module | Version | Description | Documentation |
|--------|---------|-------------|---------------|
| [terraform-appsync-module](./terraform-appsync-module.md) | 1.0 | GraphQL API management with AppSync | [📖 Docs](./terraform-appsync-module.md) |
| [terraform-athena-module](./terraform-athena-module.md) | 1.0 | Data analytics with Athena | [📖 Docs](./terraform-athena-module.md) |
| [terraform-bedrock-module](./terraform-bedrock-module.md) | 1.0 | AI/ML agents with Amazon Bedrock | [📖 Docs](./terraform-bedrock-module.md) |
| [terraform-cloudfront-module](./terraform-cloudfront-module.md) | 1.0 | CDN distribution with CloudFront | [📖 Docs](./terraform-cloudfront-module.md) |
| [terraform-cognito-module](./terraform-cognito-module.md) | 1.0 | User authentication with Cognito | [📖 Docs](./terraform-cognito-module.md) |
| [terraform-dynamodb-module](./terraform-dynamodb-module.md) | 1.0 | NoSQL database with DynamoDB | [📖 Docs](./terraform-dynamodb-module.md) |
| [terraform-ec2-module](./terraform-ec2-module.md) | 1.0 | EC2 instances and key management | [📖 Docs](./terraform-ec2-module.md) |
| [terraform-ec2-alb-module](./terraform-ec2-alb-module.md) | 1.0 | Application Load Balancer for EC2 | [📖 Docs](./terraform-ec2-alb-module.md) |
| [terraform-ecr-module](./terraform-ecr-module.md) | 1.0 | Container registry with ECR | [📖 Docs](./terraform-ecr-module.md) |
| [terraform-ecs-cluster-module](./terraform-ecs-cluster-module.md) | 1.0 | ECS cluster management | [📖 Docs](./terraform-ecs-cluster-module.md) |
| [terraform-ecs-service-module](./terraform-ecs-service-module.md) | 1.0 | ECS services and task definitions | [📖 Docs](./terraform-ecs-service-module.md) |
| [terraform-ecs-alb-module](./terraform-ecs-alb-module.md) | 1.0 | Application Load Balancer for ECS | [📖 Docs](./terraform-ecs-alb-module.md) |
| [terraform-iam-module](./terraform-iam-module.md) | 1.0 | IAM roles and policies | [📖 Docs](./terraform-iam-module.md) |
| [terraform-identity-provider-module](./terraform-identity-provider-module.md) | 1.0 | GitHub OIDC identity provider | [📖 Docs](./terraform-identity-provider-module.md) |
| [terraform-lambda-module](./terraform-lambda-module.md) | 1.0 | Serverless functions with Lambda | [📖 Docs](./terraform-lambda-module.md) |
| [terraform-lambda-layer-module](./terraform-lambda-layer-module.md) | 1.0 | Shared Lambda layers | [📖 Docs](./terraform-lambda-layer-module.md) |
| [terraform-r53-module](./terraform-r53-module.md) | 1.0 | DNS management with Route 53 | [📖 Docs](./terraform-r53-module.md) |
| [terraform-rds-cluster](./terraform-rds-cluster.md) | 1.0 | PostgreSQL RDS cluster | [📖 Docs](./terraform-rds-cluster.md) |
| [terraform-s3-module](./terraform-s3-module.md) | 1.0 | Object storage with S3 | [📖 Docs](./terraform-s3-module.md) |
| [terraform-secrets-manager-module](./terraform-secrets-manager-module.md) | 1.0 | Secret management | [📖 Docs](./terraform-secrets-manager-module.md) |
| [terraform-security-groups-module](./terraform-security-groups-module.md) | 1.0 | Network security groups | [📖 Docs](./terraform-security-groups-module.md) |
| [terraform-state-machine-module](./terraform-state-machine-module.md) | 1.0 | Step Functions state machines | [📖 Docs](./terraform-state-machine-module.md) |
| [terraform-tags-module](./terraform-tags-module.md) | 1.0 | Standardized resource tagging | [📖 Docs](./terraform-tags-module.md) |

## 📖 Documentation Standards

Each module documentation includes:

- **Overview**: Purpose and use cases
- **Architecture**: How the module fits into the overall infrastructure
- **Requirements**: Terraform version, providers, and dependencies
- **Usage**: Basic and advanced usage examples
- **Inputs**: All input variables with descriptions, types, and defaults
- **Outputs**: All output values with descriptions
- **Resources**: AWS resources created by the module
- **Examples**: Working examples for different scenarios

## 🔧 Generating Documentation

Module documentation is automatically generated using `terraform-docs`:

```bash
# Generate documentation for a single module
cd terraform-appsync-module
terraform-docs markdown table . > ../docs/modules/terraform-appsync-module.md

# Generate documentation for all modules
for dir in terraform-*-module terraform-rds-cluster; do
  if [ -d "$dir" ]; then
    echo "Generating docs for $dir..."
    cd "$dir"
    terraform-docs markdown table . > "../docs/modules/$dir.md"
    cd ..
  fi
done
```

## 📚 Module Categories

### Core Infrastructure
- **terraform-security-groups-module**: Network security
- **terraform-iam-module**: Access management
- **terraform-tags-module**: Resource organization

### Compute & Containers
- **terraform-ec2-module**: Virtual machines
- **terraform-ecs-cluster-module**: Container orchestration
- **terraform-ecs-service-module**: Container services
- **terraform-lambda-module**: Serverless functions

### Storage & Databases
- **terraform-s3-module**: Object storage
- **terraform-rds-cluster**: Relational database
- **terraform-dynamodb-module**: NoSQL database

### Networking & Security
- **terraform-cloudfront-module**: Content delivery
- **terraform-cognito-module**: Authentication
- **terraform-secrets-manager-module**: Secret management

### AI/ML & Analytics
- **terraform-bedrock-module**: AI/ML services
- **terraform-athena-module**: Data analytics
- **terraform-appsync-module**: GraphQL APIs

### DevOps & Automation
- **terraform-ecr-module**: Container registry
- **terraform-identity-provider-module**: CI/CD integration
- **terraform-state-machine-module**: Workflow orchestration

## 🚀 Usage Patterns

### Basic Module Usage

```hcl
module "example_module" {
  source = "./terraform-module-name"
  
  # Required variables
  project     = var.project
  environment = var.environment
  region      = var.aws_region
  
  # Optional variables
  custom_setting = "value"
}
```

### Advanced Module Usage

```hcl
module "example_module" {
  source = "./terraform-module-name"
  
  # Use outputs from other modules
  vpc_id    = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids
  
  # Conditional configuration
  enable_monitoring = var.environment == "prod"
  
  # Tags from tags module
  tags = module.tags.common_tags
}
```

## 🔄 Module Lifecycle

### Development
1. Create module in dedicated directory
2. Follow naming conventions and structure
3. Write comprehensive tests
4. Generate documentation

### Testing
1. Validate syntax and formatting
2. Test in development environment
3. Security scan with Checkov
4. Performance and cost analysis

### Release
1. Version tag following semantic versioning
2. Update module index and documentation
3. Announce to team
4. Monitor for issues

### Maintenance
1. Regular security updates
2. Dependency updates
3. Performance optimizations
4. Bug fixes and improvements

## 📋 Module Checklist

When creating or updating modules, ensure:

- [ ] **Structure**: Follows standard file organization
- [ ] **Variables**: All inputs documented with types and descriptions
- [ ] **Outputs**: All outputs documented with descriptions
- [ ] **Examples**: Working usage examples provided
- [ ] **Validation**: Input validation where appropriate
- [ ] **Security**: Follows security best practices
- [ ] **Tags**: Consistent tagging applied
- [ ] **Documentation**: Generated and up-to-date
- [ ] **Testing**: Tested in development environment

## 📞 Support

For module-specific questions:
- Check the individual module documentation
- Review examples in the module directory
- Contact the module maintainer
- Create an issue in the repository

---

**Last Updated**: 2025-08-22  
**Documentation Generated**: terraform-docs v0.16.0  
**Maintained By**: Infrastructure Team