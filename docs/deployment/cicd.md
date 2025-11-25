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

# CI/CD Pipeline and Release Process

This document outlines the Continuous Integration and Continuous Deployment (CI/CD) pipeline, release processes, and automation strategies for the Lecture Infrastructure project.

## 📋 Table of Contents

- [Pipeline Overview](#pipeline-overview)
- [Current CI/CD Setup](#current-cicd-setup)
- [Pipeline Stages](#pipeline-stages)
- [Release Process](#release-process)
- [Environment Promotion](#environment-promotion)
- [Security and Compliance](#security-and-compliance)
- [Troubleshooting](#troubleshooting)

## 🔄 Pipeline Overview

### CI/CD Architecture

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Developer │    │   GitHub    │    │   GitHub    │    │   AWS       │
│   Commits   │───▶│   Repository│───▶│   Actions   │───▶│   Accounts  │
│             │    │             │    │   Workflow  │    │             │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
                                               │
                                               ▼
                   ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
                   │   Security  │    │   Testing   │    │ Deployment  │
                   │   Scanning  │    │   & Validation │   │ to Customer │
                   │   (Checkov) │    │   (terraform)  │   │ Environments│
                   └─────────────┘    └─────────────┘    └─────────────┘
```

### Repository Structure for CI/CD

```
.
├── .github/
│   └── workflows/
│       ├── main.yml                    # Current Checkov security scanning
│       ├── terraform-plan.yml          # Planned: Terraform validation
│       ├── terraform-apply.yml         # Planned: Infrastructure deployment
│       └── release.yml                 # Planned: Release automation
├── scripts/
│   ├── deploy.sh                       # Deployment automation
│   ├── test-infrastructure.sh          # Infrastructure testing
│   └── validate-terraform.sh           # Terraform validation
└── terraform configuration files...
```

## 🚀 Current CI/CD Setup

### Existing GitHub Actions Workflow

The current `.github/workflows/main.yml` provides security scanning:

```yaml
name: Checkov
on:
  push:
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Set up Python 3.8
        uses: actions/setup-python@v4
        with:
          python-version: 3.8
      - name: Test with Checkov
        id: checkov
        uses: bridgecrewio/checkov-action@master
        with:
          directory: .
          framework: terraform
```

### Current Deployment Process

Manual deployment using the provided script:

```bash
# Current manual deployment process
export CUSTOMER="dhbw"  # or other customer
export AWS_PROFILE="lecture-$CUSTOMER-prod"

# Script-based deployment
./scripts.sh

# Or manual steps:
terraform init -backend-config="lecture-$CUSTOMER-prod-backend.hcl" -reconfigure
terraform fmt --recursive .
terraform validate
terraform apply -var-file="lecture-$CUSTOMER-prod-variables.tfvars"
```

## 🏗️ Pipeline Stages

### Stage 1: Code Quality and Security (Existing)

```yaml
# .github/workflows/code-quality.yml
name: Code Quality and Security
on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  security-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Run Checkov
        uses: bridgecrewio/checkov-action@master
        with:
          directory: .
          framework: terraform
          soft_fail: false
          
      - name: Terraform Format Check
        run: terraform fmt -check -recursive .
        
      - name: Terraform Validation
        run: |
          terraform init -backend=false
          terraform validate
```

### Stage 2: Infrastructure Validation (Planned)

```yaml
# .github/workflows/terraform-validation.yml
name: Terraform Validation
on:
  pull_request:
    branches: [main]

jobs:
  validate:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        customer: [test, dhbw, edt, unilux]
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: 1.12.2
          
      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
          aws-region: eu-central-1
          
      - name: Terraform Plan
        run: |
          terraform init -backend-config="lecture-${{ matrix.customer }}-prod-backend.hcl"
          terraform plan -var-file="lecture-${{ matrix.customer }}-prod-variables.tfvars" -no-color
```

### Stage 3: Testing (Planned)

```yaml
# .github/workflows/infrastructure-tests.yml
name: Infrastructure Tests
on:
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Test Infrastructure
        run: |
          # Module validation tests
          for module in terraform-*-module; do
            if [ -d "$module" ]; then
              echo "Testing $module..."
              cd "$module"
              terraform init -backend=false
              terraform validate
              terraform fmt -check
              cd ..
            fi
          done
          
      - name: Run TFLint
        uses: terraform-linters/setup-tflint@v2
        with:
          tflint_version: latest
          
      - name: Initialize TFLint
        run: tflint --init
        
      - name: Run TFLint
        run: tflint --recursive
```

### Stage 4: Deployment (Planned)

```yaml
# .github/workflows/deployment.yml
name: Deploy Infrastructure
on:
  push:
    branches: [main]
  workflow_dispatch:
    inputs:
      customer:
        description: 'Customer environment to deploy'
        required: true
        type: choice
        options:
          - test
          - dhbw
          - edt
          - unilux
          - gva
          - santillana
          - educaria
          - ufv
          - edtufv

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: production
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: 1.12.2
          
      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
          aws-region: eu-central-1
          
      - name: Deploy Infrastructure
        run: |
          export CUSTOMER="${{ github.event.inputs.customer || 'test' }}"
          export AWS_PROFILE="lecture-$CUSTOMER-prod"
          
          terraform init -backend-config="lecture-$CUSTOMER-prod-backend.hcl" -reconfigure
          terraform apply -var-file="lecture-$CUSTOMER-prod-variables.tfvars" -auto-approve
          
      - name: Verify Deployment
        run: |
          # Health checks and verification
          ./scripts/verify-deployment.sh ${{ github.event.inputs.customer }}
```

## 📦 Release Process

### Semantic Versioning

The project follows [Semantic Versioning](https://semver.org/):

- **MAJOR** (X.0.0): Breaking changes requiring manual intervention
- **MINOR** (0.X.0): New features, backward-compatible changes
- **PATCH** (0.0.X): Bug fixes, security patches

### Release Types

#### 1. Hotfix Release (Emergency)
```bash
# Emergency security patch or critical bug fix
git checkout main
git checkout -b hotfix/security-patch-v2.1.1
# Make necessary changes
git commit -m "fix: critical security vulnerability in IAM policies"
git push origin hotfix/security-patch-v2.1.1
# Create PR, review, merge to main
git tag v2.1.1
git push origin v2.1.1
```

#### 2. Regular Release (Weekly)
```bash
# Planned feature release
git checkout develop
git checkout -b release/v2.2.0
# Final testing and documentation updates
git commit -m "chore: prepare release v2.2.0"
git checkout main
git merge release/v2.2.0
git tag v2.2.0
git push origin v2.2.0
```

#### 3. Major Release (Quarterly)
```bash
# Major architectural changes
git checkout develop
git checkout -b release/v3.0.0
# Breaking changes, migration scripts
git commit -m "feat!: migrate to new module structure"
git checkout main
git merge release/v3.0.0
git tag v3.0.0
git push origin v3.0.0
```

### Release Automation (Planned)

```yaml
# .github/workflows/release.yml
name: Release
on:
  push:
    tags:
      - 'v*'

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
          
      - name: Generate Changelog
        uses: orhun/git-cliff-action@v2
        with:
          config: cliff.toml
          args: --verbose
          
      - name: Create Release
        uses: softprops/action-gh-release@v1
        with:
          body_path: CHANGELOG.md
          draft: false
          prerelease: ${{ contains(github.ref, 'alpha') || contains(github.ref, 'beta') }}
          
      - name: Notify Teams
        run: |
          curl -X POST -H 'Content-type: application/json' \
            --data '{"text":"New release ${{ github.ref_name }} is available!"}' \
            ${{ secrets.SLACK_WEBHOOK_URL }}
```

## 🔄 Environment Promotion

### Environment Strategy

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│ Development │───▶│   Staging   │───▶│ Production  │
│ (test env)  │    │ (pre-prod)  │    │ (customers) │
└─────────────┘    └─────────────┘    └─────────────┘
```

### Promotion Process

#### 1. Development to Staging
```bash
# Automated promotion after successful development tests
export CUSTOMER="test"
terraform apply -var-file="lecture-test-prod-variables.tfvars"
./scripts/run-integration-tests.sh test
```

#### 2. Staging to Production
```bash
# Manual promotion with approval
for customer in dhbw edt unilux gva santillana educaria ufv edtufv; do
  echo "Deploying to $customer..."
  export CUSTOMER="$customer"
  terraform plan -var-file="lecture-$customer-prod-variables.tfvars"
  # Manual approval required
  read -p "Deploy to $customer? (y/N): " confirm
  if [[ $confirm == [yY] ]]; then
    terraform apply -var-file="lecture-$customer-prod-variables.tfvars"
    ./scripts/verify-deployment.sh $customer
  fi
done
```

### Deployment Gates

#### Automated Gates
- [ ] All tests pass
- [ ] Security scan passes (Checkov)
- [ ] Terraform validation passes
- [ ] No high/critical vulnerabilities

#### Manual Gates
- [ ] Code review approval (2 reviewers)
- [ ] Architecture review (for major changes)
- [ ] Security review (for security-related changes)
- [ ] Customer impact assessment

## 🔐 Security and Compliance

### GitHub Actions Security

#### Secrets Management
```yaml
# Required GitHub Secrets
AWS_ROLE_ARN: arn:aws:iam::ACCOUNT:role/GitHubActionsRole
SLACK_WEBHOOK_URL: https://hooks.slack.com/services/...
GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }} # Automatically provided
```

#### OIDC Integration with AWS
```yaml
# Configure AWS credentials using OIDC
- name: Configure AWS Credentials
  uses: aws-actions/configure-aws-credentials@v2
  with:
    role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
    role-session-name: GitHubActions
    aws-region: eu-central-1
```

#### IAM Role for GitHub Actions
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::ACCOUNT:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:organization/lecture-infrastructure:*"
        }
      }
    }
  ]
}
```

### Compliance Checks

#### Automated Compliance
```yaml
# Compliance validation in CI/CD
- name: Run Compliance Checks
  run: |
    # Check for required tags
    terraform plan -out=plan.tfplan
    terraform show -json plan.tfplan | jq '.planned_values.root_module.resources[] | select(.values.tags.Environment == null)'
    
    # Verify encryption settings
    checkov -f plan.tfplan --check CKV_AWS_20,CKV_AWS_21
    
    # Validate backup configurations
    ./scripts/validate-backups.sh
```

## 🔧 Pipeline Enhancement Roadmap

### Phase 1: Foundation (Current)
- [x] Basic security scanning with Checkov
- [x] Manual deployment process
- [x] Customer-specific configurations

### Phase 2: Automation (Next Quarter)
- [ ] Automated Terraform validation
- [ ] Infrastructure testing pipeline
- [ ] Deployment automation with approval gates
- [ ] Release automation

### Phase 3: Advanced Features (6 months)
- [ ] Multi-environment testing
- [ ] Performance testing integration
- [ ] Automated rollback capabilities
- [ ] Blue-green deployment support

### Phase 4: Optimization (1 year)
- [ ] Predictive scaling based on usage patterns
- [ ] Cost optimization automation
- [ ] Advanced security scanning integration
- [ ] Customer self-service deployment portal

## 🔍 Monitoring and Metrics

### Pipeline Metrics

#### Key Performance Indicators
- **Deployment Frequency**: Target: Weekly releases
- **Lead Time**: From commit to production deployment
- **Mean Time to Recovery (MTTR)**: Time to fix failed deployments
- **Change Failure Rate**: Percentage of deployments causing issues

#### Pipeline Health Dashboard
```yaml
# CloudWatch metrics for pipeline monitoring
- DeploymentSuccess: Success/failure rate
- DeploymentDuration: Time taken for deployments
- TestCoverage: Infrastructure test coverage
- SecurityIssues: Number of security issues found
```

### Alerting

#### Pipeline Alerts
```bash
# Slack notifications for pipeline events
curl -X POST -H 'Content-type: application/json' \
  --data '{
    "text": "🚨 Deployment failed for customer '$CUSTOMER'",
    "attachments": [{
      "color": "danger",
      "fields": [{
        "title": "Error",
        "value": "'$ERROR_MESSAGE'",
        "short": false
      }]
    }]
  }' \
  $SLACK_WEBHOOK_URL
```

## 🛠️ Troubleshooting

### Common Pipeline Issues

#### 1. Terraform State Lock
```bash
# Error: Error acquiring the state lock
# Solution: Check for stuck locks
aws dynamodb scan --table-name terraform-state-lock
# Force unlock if necessary (use with caution)
terraform force-unlock LOCK_ID
```

#### 2. AWS Credentials Issues
```bash
# Error: Unable to assume role
# Check OIDC provider configuration
aws iam get-openid-connect-provider \
  --open-id-connect-provider-arn arn:aws:iam::ACCOUNT:oidc-provider/token.actions.githubusercontent.com

# Verify role trust policy
aws iam get-role --role-name GitHubActionsRole
```

#### 3. Checkov Security Failures
```bash
# Error: Checkov found security issues
# Review specific issues
checkov -d . --framework terraform --soft-fail

# Common fixes:
# - Enable encryption: storage_encrypted = true
# - Add backup retention: backup_retention_period = 7
# - Configure security groups properly
```

#### 4. Module Validation Errors
```bash
# Error: Module validation failed
# Check module structure
for module in terraform-*-module; do
  echo "Validating $module..."
  cd "$module"
  terraform init -backend=false
  terraform validate
  cd ..
done
```

### Pipeline Debugging

#### GitHub Actions Debugging
```yaml
# Enable debug logging
- name: Debug Information
  run: |
    echo "Runner OS: $RUNNER_OS"
    echo "GitHub Event: $GITHUB_EVENT_NAME"
    echo "GitHub Ref: $GITHUB_REF"
    echo "AWS Region: $AWS_DEFAULT_REGION"
    
    # Terraform debugging
    export TF_LOG=DEBUG
    terraform --version
```

#### Local Testing
```bash
# Test pipeline locally using act
brew install act  # or appropriate package manager
act -j test  # Run specific job
act push    # Simulate push event
```

## 📞 Support and Contacts

### CI/CD Team Contacts
- **DevOps Lead**: devops-lead@company.com
- **Platform Engineer**: platform-eng@company.com
- **Security Engineer**: security-eng@company.com

### Escalation Process
1. **Pipeline Failures**: DevOps team → Platform team
2. **Security Issues**: Security team → CISO
3. **Customer Impact**: Customer success → Management

---

**Last Updated**: 2025-08-22  
**Version**: 2.0  
**Next Review**: 2025-11-22  
**Owner**: DevOps Team