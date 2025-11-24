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

# ADR-002: AWS Services Selection

## Status
Accepted

## Context

The Lecture Infrastructure requires a comprehensive cloud platform that supports:
- Container orchestration for microservices
- Managed databases with high availability
- Object storage for content and media files
- Serverless computing for event-driven tasks
- AI/ML capabilities for content processing
- Authentication and authorization
- Content delivery network
- Analytics and monitoring

We need to select specific AWS services that provide the best balance of functionality, cost, operational simplicity, and team expertise.

## Decision

We will use the following AWS services as the foundation for the Lecture Infrastructure:

### Core Compute Services
- **Amazon ECS (Fargate)**: Container orchestration without server management
- **AWS Lambda**: Serverless computing for event-driven functions
- **EC2 (minimal)**: Only for specific use cases requiring dedicated compute

### Storage and Database
- **Amazon RDS Aurora PostgreSQL**: Managed relational database with clustering
- **Amazon DynamoDB**: NoSQL database for high-performance data access
- **Amazon S3**: Object storage for content, media, and backups

### Networking and Security
- **Amazon VPC**: Virtual private cloud with public/private subnets
- **Amazon CloudFront**: Global content delivery network
- **AWS Cognito**: User authentication and authorization
- **AWS WAF**: Web application firewall protection

### AI/ML and Analytics
- **Amazon Bedrock**: Managed AI/ML services for content processing
- **Amazon Athena**: Serverless analytics for log and data analysis
- **AWS AppSync**: Managed GraphQL API service

### Integration and Orchestration
- **AWS Step Functions**: Workflow orchestration for complex processes
- **Amazon EventBridge**: Event routing and processing
- **AWS Systems Manager**: Configuration management and secrets

### Monitoring and Operations
- **Amazon CloudWatch**: Monitoring, logging, and alerting
- **AWS CloudTrail**: API logging and audit trails
- **AWS Config**: Configuration compliance monitoring

## Consequences

### Positive

- **Managed Services**: Reduced operational overhead for database, containers, and AI/ML
- **Scalability**: Auto-scaling capabilities across compute and storage services
- **Security**: Built-in security features and compliance certifications
- **Integration**: Native integration between AWS services
- **Cost Optimization**: Pay-as-you-use pricing models
- **Global Reach**: Multi-region capabilities for performance and DR
- **Team Expertise**: Leverages existing AWS knowledge and skills

### Negative

- **Vendor Lock-in**: Strong dependency on AWS ecosystem
- **Cost Complexity**: Complex pricing models across multiple services
- **Service Limits**: AWS service quotas may require management
- **Learning Curve**: New services like Bedrock require team training
- **Regional Limitations**: Some services not available in all regions

### Neutral

- **Service Evolution**: AWS services continue to evolve and improve
- **Support Model**: Enterprise support available but at additional cost
- **Compliance**: Most services meet major compliance requirements

## Alternatives Considered

### 1. Multi-Cloud Approach (AWS + Azure/GCP)
**Pros**: Reduced vendor lock-in, best-of-breed services
**Cons**: Increased complexity, integration challenges, operational overhead
**Rejected**: Team expertise concentrated in AWS, unnecessary complexity

### 2. Kubernetes on EC2
**Pros**: Greater control, container portability, industry standard
**Cons**: Operational complexity, team expertise gap, management overhead
**Rejected**: ECS Fargate provides container benefits with less complexity

### 3. Self-Managed Database on EC2
**Pros**: Full control, potential cost savings
**Cons**: Operational burden, backup complexity, high availability challenges
**Rejected**: RDS Aurora provides better reliability and less operational overhead

### 4. Traditional VM-based Architecture
**Pros**: Familiar patterns, full control
**Cons**: Scalability challenges, operational overhead, cost inefficiency
**Rejected**: Containerization provides better resource utilization

## Service-Specific Rationale

### Amazon ECS Fargate vs. EKS
- **ECS Chosen**: Simpler operational model, better AWS integration
- **Team Expertise**: Existing experience with ECS
- **Cost**: More predictable pricing than EKS

### RDS Aurora vs. Self-Managed PostgreSQL
- **Aurora Chosen**: Automated backups, clustering, monitoring
- **High Availability**: Multi-AZ deployment built-in
- **Performance**: Better performance optimization features

### S3 vs. Alternative Object Storage
- **S3 Chosen**: Industry standard, extensive ecosystem integration
- **Durability**: 99.999999999% durability guarantee
- **Features**: Lifecycle policies, versioning, encryption

### Lambda vs. Container-based Functions
- **Lambda Chosen**: True serverless model, automatic scaling
- **Cost Efficiency**: Pay only for execution time
- **Integration**: Native AWS service integration

### Bedrock vs. Self-Hosted AI/ML
- **Bedrock Chosen**: Managed service reduces operational complexity
- **Model Access**: Access to state-of-the-art foundation models
- **Compliance**: Built-in security and compliance features

## Implementation Guidelines

### Service Configuration Standards

```hcl
# Example: RDS Aurora configuration
resource "aws_rds_cluster" "main" {
  cluster_identifier = "${var.project}-${var.environment}-cluster"
  engine            = "aurora-postgresql"
  engine_version    = "13.7"
  
  # Always enable encryption
  storage_encrypted = true
  kms_key_id       = aws_kms_key.database.arn
  
  # Enable monitoring
  enabled_cloudwatch_logs_exports = ["postgresql"]
  monitoring_interval            = 60
  
  # Backup configuration
  backup_retention_period = var.backup_retention_period
  preferred_backup_window = "03:00-04:00"
  
  # Production-grade settings
  deletion_protection = var.environment == "prod"
}
```

### Cost Optimization Guidelines

1. **Right-sizing**: Use appropriate instance types for workloads
2. **Reserved Instances**: Purchase RIs for stable workloads
3. **Spot Instances**: Use for non-critical, fault-tolerant workloads
4. **S3 Lifecycle**: Implement lifecycle policies for cost optimization
5. **Lambda Optimization**: Optimize memory allocation and execution time

### Security Guidelines

1. **Encryption**: Enable encryption at rest and in transit for all services
2. **IAM**: Use least privilege access principles
3. **VPC**: Implement proper network segmentation
4. **WAF**: Enable web application firewall for public endpoints
5. **Monitoring**: Enable CloudTrail and Config for audit logging

## Migration Strategy

### Phase 1: Core Infrastructure
- [x] VPC and networking setup
- [x] ECS cluster deployment
- [x] RDS Aurora database
- [x] S3 buckets for storage

### Phase 2: Application Services
- [x] Lambda functions for processing
- [x] Cognito for authentication
- [x] AppSync for GraphQL APIs
- [x] CloudFront for content delivery

### Phase 3: Advanced Features
- [x] Bedrock for AI/ML capabilities
- [x] Step Functions for orchestration
- [x] Athena for analytics
- [x] Advanced monitoring and alerting

## Cost Estimation

### Monthly Cost Breakdown (per customer, production environment)
- **ECS Fargate**: $200-400 (depending on scale)
- **RDS Aurora**: $150-300 (depending on instance size)
- **S3 Storage**: $50-200 (depending on usage)
- **Lambda**: $20-100 (depending on executions)
- **CloudFront**: $30-150 (depending on traffic)
- **Other Services**: $100-200
- **Total Estimated**: $550-1,350 per customer per month

## Monitoring and Review

### Service Performance Metrics
- **Availability**: Target 99.9% uptime across all services
- **Performance**: Response time SLAs per service
- **Cost**: Monthly cost per customer tracking
- **Security**: Zero security incidents related to service configuration

### Regular Reviews
- **Monthly**: Service utilization and cost optimization review
- **Quarterly**: Performance and reliability assessment
- **Annually**: Service selection review and potential alternatives evaluation

## Related ADRs

- ADR-001: Multi-Tenant Architecture Design
- ADR-004: Container Orchestration with ECS
- ADR-005: Database Architecture Design
- ADR-008: AI/ML Integration with Bedrock

---

**Decision Date**: 2025-08-22  
**Decision Makers**: Architecture Team, CTO, DevOps Lead  
**Stakeholders**: Development Team, Operations Team, Finance Team