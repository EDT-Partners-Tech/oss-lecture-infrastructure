<!-- © [2025] EDT&Partners. Licensed under CC BY 4.0. -->
# Deployment Guide

This guide provides detailed instructions for deploying the lecture infrastructure across different customer environments.

## 📋 Prerequisites

### Required Tools

- **Terraform**: >= 1.12.0 (recommended: latest version)
- **AWS CLI**: v2 with configured profiles
- **Git**: For version control
- **jq**: For JSON processing (optional but recommended)

### AWS Access Requirements

- Access to customer-specific AWS accounts
- IAM permissions for all services used (see [IAM Requirements](#iam-requirements))
- S3 bucket for Terraform state (already configured per customer)

### Environment Setup

```bash
# Install required tools (macOS with Homebrew)
brew install terraform awscli jq

# Install required tools (Ubuntu/Debian)
sudo apt-get update
sudo apt-get install terraform awscli jq

# Verify installations
terraform version
aws --version
```

## 🎯 Customer Environments

### Available Customers

| Customer | Environment | AWS Profile | Region |
|----------|-------------|-------------|---------|
| DHBW | Production | `lecture-dhbw-prod` | eu-central-1 |
| EDT | Production | `lecture-edt-prod` | us-east-1 |
| EDT UFV | Production | `lecture-edtufv-prod` | eu-central-1 |
| Educaria | Production | `lecture-educaria-prod` | eu-central-1 |
| GVA | Production | `lecture-gva-prod` | eu-central-1 |
| Santillana | Production | `lecture-santillana-prod` | eu-central-1 |
| UFV | Production | `lecture-ufv-prod` | eu-central-1 |
| Unilux | Production | `lecture-unilux-prod` | eu-central-1 |
| Test | Testing | `lecture-test-prod` | us-east-1 |

### Configuration Files

Each customer has dedicated configuration files:
- **Backend**: `lecture-{customer}-prod-backend.hcl`
- **Variables**: `lecture-{customer}-prod-variables.tfvars`

## 🚀 Deployment Process

### Step 1: Environment Selection

```bash
# Set customer environment
export CUSTOMER="dhbw"  # Replace with your target customer
export AWS_PROFILE="lecture-$CUSTOMER-prod"

# Verify AWS access
aws sts get-caller-identity --profile $AWS_PROFILE
```

### Step 2: Terraform Initialization

```bash
# Initialize Terraform with customer-specific backend
terraform init \
  -backend-config="lecture-$CUSTOMER-prod-backend.hcl" \
  -reconfigure
```

### Step 3: Plan and Review

```bash
# Generate execution plan
terraform plan \
  -var-file="lecture-$CUSTOMER-prod-variables.tfvars" \
  -out="$CUSTOMER.tfplan"

# Review the plan thoroughly before applying
```

### Step 4: Apply Infrastructure

```bash
# Apply the infrastructure changes
terraform apply "$CUSTOMER.tfplan"

# Or apply with auto-approval (use with caution)
terraform apply \
  -var-file="lecture-$CUSTOMER-prod-variables.tfvars" \
  -auto-approve
```

### Step 5: Verification

```bash
# Verify deployment
terraform output

# Check specific resources
aws ecs list-clusters --profile $AWS_PROFILE
aws s3 ls --profile $AWS_PROFILE
```

## 🔄 Automated Deployment Script

Use the provided `scripts.sh` for automated deployment:

```bash
# Edit scripts.sh to set your customer
vim scripts.sh

# Run the deployment script
./scripts.sh
```

## 🎛️ Advanced Deployment Options

### Targeted Deployment

Deploy specific modules only:

```bash
# Deploy only Route 53 resources first
terraform apply \
  -var-file="lecture-$CUSTOMER-prod-variables.tfvars" \
  -target=module.multiaccount_r53

# Then deploy everything else
terraform apply \
  -var-file="lecture-$CUSTOMER-prod-variables.tfvars"
```

### Environment-Specific Overrides

```bash
# Override specific variables
terraform apply \
  -var-file="lecture-$CUSTOMER-prod-variables.tfvars" \
  -var="environment=staging" \
  -var="instance_count=1"
```

## 🔐 Security Considerations

### State File Security

- Terraform state is stored in encrypted S3 buckets
- State locking via DynamoDB prevents concurrent modifications
- Each customer has isolated state storage

### Secrets Management

- Never commit secrets to version control
- Use AWS Secrets Manager for sensitive values
- GitHub tokens should be stored in GitHub Actions secrets

### Access Control

- Use least-privilege IAM policies
- Regularly rotate access keys
- Enable CloudTrail for audit logging

## 🛠️ Troubleshooting

### Common Issues

#### 1. Authentication Errors
```bash
# Verify AWS credentials
aws configure list --profile $AWS_PROFILE
aws sts get-caller-identity --profile $AWS_PROFILE
```

#### 2. State Lock Issues
```bash
# If state is locked, check DynamoDB
aws dynamodb scan --table-name terraform-state-lock --profile $AWS_PROFILE

# Force unlock (use with extreme caution)
terraform force-unlock LOCK_ID
```

#### 3. Resource Conflicts
```bash
# Import existing resources
terraform import aws_s3_bucket.example bucket-name

# Refresh state
terraform refresh -var-file="lecture-$CUSTOMER-prod-variables.tfvars"
```

#### 4. Version Conflicts
```bash
# Upgrade providers
terraform init -upgrade

# Check provider versions
terraform providers
```

### Rollback Procedures

```bash
# Rollback to previous state
terraform apply -var-file="lecture-$CUSTOMER-prod-variables.tfvars" -auto-approve

# Or destroy and recreate (last resort)
terraform destroy -var-file="lecture-$CUSTOMER-prod-variables.tfvars"
```

## 📊 Post-Deployment Validation

### Health Checks

1. **ECS Services**: Verify all services are running
2. **Lambda Functions**: Check function invocations
3. **RDS Cluster**: Confirm database connectivity
4. **S3 Buckets**: Validate bucket policies and encryption
5. **CloudFront**: Test CDN distribution

### Monitoring Setup

1. Enable CloudWatch alarms
2. Configure log aggregation
3. Set up application metrics
4. Test alerting mechanisms

## 🔄 Updates and Maintenance

### Regular Updates

1. **Weekly**: Check for Terraform provider updates
2. **Monthly**: Review and update module versions
3. **Quarterly**: Security audit and compliance review

### Emergency Updates

For critical security patches:
1. Test in development environment first
2. Apply during maintenance windows
3. Monitor for issues post-deployment
4. Have rollback plan ready

## 📞 Support

For deployment issues:
- Check the [Operations Runbook](../operations/runbook.md)
- Review CloudWatch logs
- Contact infrastructure team
- Create incident ticket if needed

## 📝 Deployment Checklist

- [ ] AWS credentials configured
- [ ] Terraform version verified
- [ ] Customer environment selected
- [ ] Backend initialized
- [ ] Plan reviewed and approved
- [ ] Infrastructure applied successfully
- [ ] Post-deployment validation completed
- [ ] Monitoring and alerts configured
- [ ] Documentation updated
- [ ] Team notified of changes

---

**Last Updated**: 2025-08-22  
**Version**: 2.0