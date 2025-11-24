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

# Operations Runbook

This runbook provides step-by-step procedures for common operational tasks, troubleshooting, and incident response for the Lecture Infrastructure.

## 📋 Table of Contents

- [Emergency Contacts](#emergency-contacts)
- [Common Operations](#common-operations)
- [Troubleshooting](#troubleshooting)
- [Monitoring & Alerts](#monitoring--alerts)
- [Incident Response](#incident-response)
- [Maintenance Procedures](#maintenance-procedures)

## 🚨 Emergency Contacts

### Escalation Matrix

| Severity | Contact | Response Time | Contact Method |
|----------|---------|---------------|----------------|
| P0 (Critical) | On-call Engineer | 15 minutes | Phone + Slack |
| P1 (High) | Team Lead | 1 hour | Slack + Email |
| P2 (Medium) | Infrastructure Team | 4 hours | Slack |
| P3 (Low) | Infrastructure Team | Next business day | Email |

### Contact Information

- **On-call Engineer**: Check PagerDuty rotation
- **Team Lead**: infrastructure-lead@company.com
- **Security Team**: security@company.com
- **AWS Support**: Use Enterprise Support portal

## 🔧 Common Operations

### Customer Environment Management

#### Switching Between Customers

```bash
# Set customer environment
export CUSTOMER="dhbw"  # or edt, unilux, etc.
export AWS_PROFILE="lecture-$CUSTOMER-prod"

# Verify access
aws sts get-caller-identity --profile $AWS_PROFILE

# Initialize Terraform
terraform init -backend-config="lecture-$CUSTOMER-prod-backend.hcl" -reconfigure
```

#### Checking Customer Status

```bash
# Check ECS services
aws ecs list-clusters --profile $AWS_PROFILE
aws ecs list-services --cluster lecture-$CUSTOMER-cluster --profile $AWS_PROFILE

# Check RDS status
aws rds describe-db-clusters --profile $AWS_PROFILE

# Check S3 buckets
aws s3 ls --profile $AWS_PROFILE
```

### Deployment Operations

#### Standard Deployment

```bash
# Plan deployment
terraform plan -var-file="lecture-$CUSTOMER-prod-variables.tfvars" -out="$CUSTOMER.tfplan"

# Review plan thoroughly
terraform show "$CUSTOMER.tfplan"

# Apply deployment
terraform apply "$CUSTOMER.tfplan"
```

#### Emergency Rollback

```bash
# Quick rollback using previous state
terraform apply -var-file="lecture-$CUSTOMER-prod-variables.tfvars" -auto-approve

# If state is corrupted, restore from backup
aws s3 cp s3://terraform-state-backup/lecture-$CUSTOMER/terraform.tfstate.backup terraform.tfstate
terraform refresh -var-file="lecture-$CUSTOMER-prod-variables.tfvars"
```

### Resource Management

#### Scaling ECS Services

```bash
# Scale up service
aws ecs update-service \
  --cluster lecture-$CUSTOMER-cluster \
  --service lecture-backend-service \
  --desired-count 3 \
  --profile $AWS_PROFILE

# Monitor scaling progress
aws ecs describe-services \
  --cluster lecture-$CUSTOMER-cluster \
  --services lecture-backend-service \
  --profile $AWS_PROFILE
```

#### Managing Lambda Functions

```bash
# Check function status
aws lambda get-function --function-name lecture-$CUSTOMER-function --profile $AWS_PROFILE

# Update function configuration
aws lambda update-function-configuration \
  --function-name lecture-$CUSTOMER-function \
  --memory-size 512 \
  --timeout 30 \
  --profile $AWS_PROFILE
```

## 🔍 Troubleshooting

### Common Issues

#### 1. Terraform State Lock

**Symptoms**: `Error acquiring the state lock`

**Solution**:
```bash
# Check lock status
aws dynamodb scan --table-name terraform-state-lock --profile $AWS_PROFILE

# Force unlock (use with extreme caution)
terraform force-unlock LOCK_ID

# If lock persists, check for running processes
ps aux | grep terraform
```

#### 2. ECS Service Startup Failures

**Symptoms**: Tasks failing to start, service events showing errors

**Diagnosis**:
```bash
# Check service events
aws ecs describe-services \
  --cluster lecture-$CUSTOMER-cluster \
  --services lecture-backend-service \
  --profile $AWS_PROFILE

# Check task definition
aws ecs describe-task-definition \
  --task-definition lecture-backend:latest \
  --profile $AWS_PROFILE

# Check CloudWatch logs
aws logs describe-log-groups --profile $AWS_PROFILE
aws logs get-log-events \
  --log-group-name /ecs/lecture-backend \
  --log-stream-name STREAM_NAME \
  --profile $AWS_PROFILE
```

**Common Fixes**:
- Check CPU/memory allocation
- Verify environment variables
- Check security group rules
- Validate container image availability

#### 3. RDS Connection Issues

**Symptoms**: Applications cannot connect to database

**Diagnosis**:
```bash
# Check RDS cluster status
aws rds describe-db-clusters \
  --db-cluster-identifier lecture-$CUSTOMER-cluster \
  --profile $AWS_PROFILE

# Check security groups
aws ec2 describe-security-groups \
  --group-ids sg-xxxxxxxxx \
  --profile $AWS_PROFILE

# Test connectivity from ECS task
aws ecs run-task \
  --cluster lecture-$CUSTOMER-cluster \
  --task-definition debug-task \
  --profile $AWS_PROFILE
```

#### 4. S3 Access Issues

**Symptoms**: 403 Forbidden errors, upload failures

**Diagnosis**:
```bash
# Check bucket policy
aws s3api get-bucket-policy --bucket content-$CUSTOMER-prod --profile $AWS_PROFILE

# Check IAM role permissions
aws iam get-role --role-name lecture-$CUSTOMER-ecs-role --profile $AWS_PROFILE
aws iam list-attached-role-policies --role-name lecture-$CUSTOMER-ecs-role --profile $AWS_PROFILE

# Test access
aws s3 ls s3://content-$CUSTOMER-prod --profile $AWS_PROFILE
```

### Performance Issues

#### High CPU/Memory Usage

```bash
# Check ECS service metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/ECS \
  --metric-name CPUUtilization \
  --dimensions Name=ServiceName,Value=lecture-backend-service \
  --start-time 2025-08-22T00:00:00Z \
  --end-time 2025-08-22T23:59:59Z \
  --period 3600 \
  --statistics Average \
  --profile $AWS_PROFILE
```

#### Database Performance

```bash
# Check RDS metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/RDS \
  --metric-name DatabaseConnections \
  --dimensions Name=DBClusterIdentifier,Value=lecture-$CUSTOMER-cluster \
  --start-time 2025-08-22T00:00:00Z \
  --end-time 2025-08-22T23:59:59Z \
  --period 3600 \
  --statistics Average \
  --profile $AWS_PROFILE
```

## 📊 Monitoring & Alerts

### Key Metrics to Monitor

#### Application Metrics
- ECS service health and task count
- Lambda function errors and duration
- API Gateway latency and error rates
- Application logs for errors

#### Infrastructure Metrics
- EC2 instance health (if applicable)
- RDS cluster status and connections
- S3 bucket access patterns
- CloudFront cache hit rates

#### Security Metrics
- Failed authentication attempts
- Unusual API access patterns
- CloudTrail anomalies
- Security group changes

### CloudWatch Dashboards

```bash
# Create custom dashboard
aws cloudwatch put-dashboard \
  --dashboard-name "Lecture-$CUSTOMER-Overview" \
  --dashboard-body file://dashboard-config.json \
  --profile $AWS_PROFILE
```

### Setting Up Alerts

```bash
# Create CloudWatch alarm
aws cloudwatch put-metric-alarm \
  --alarm-name "ECS-Service-TaskCount-Low" \
  --alarm-description "ECS service has too few running tasks" \
  --metric-name RunningTaskCount \
  --namespace AWS/ECS \
  --statistic Average \
  --period 300 \
  --threshold 1 \
  --comparison-operator LessThanThreshold \
  --evaluation-periods 2 \
  --alarm-actions arn:aws:sns:region:account:topic-name \
  --profile $AWS_PROFILE
```

## 🚨 Incident Response

### Incident Classification

| Priority | Description | Response Time | Examples |
|----------|-------------|---------------|----------|
| P0 | Complete service outage | 15 minutes | All customers down |
| P1 | Major functionality impacted | 1 hour | Single customer down |
| P2 | Minor functionality impacted | 4 hours | Performance degradation |
| P3 | Cosmetic or minor issues | Next business day | Documentation errors |

### Response Procedures

#### P0 - Critical Incident

1. **Immediate Response** (0-15 minutes):
   ```bash
   # Check overall system status
   ./scripts/health-check.sh
   
   # Identify affected customers
   for customer in dhbw edt unilux; do
     echo "Checking $customer..."
     export AWS_PROFILE="lecture-$customer-prod"
     aws ecs describe-services --cluster lecture-$customer-cluster
   done
   ```

2. **Assessment** (15-30 minutes):
   - Determine scope and impact
   - Identify root cause
   - Estimate recovery time
   - Communicate status to stakeholders

3. **Recovery** (30+ minutes):
   - Execute recovery procedures
   - Monitor progress
   - Verify service restoration
   - Document incident

#### Recovery Procedures

##### Complete Infrastructure Recovery

```bash
# Emergency deployment from known good state
export CUSTOMER="affected-customer"
export AWS_PROFILE="lecture-$CUSTOMER-prod"

# Restore from backup if needed
aws s3 cp s3://terraform-state-backup/lecture-$CUSTOMER/terraform.tfstate.backup terraform.tfstate

# Redeploy infrastructure
terraform init -backend-config="lecture-$CUSTOMER-prod-backend.hcl"
terraform apply -var-file="lecture-$CUSTOMER-prod-variables.tfvars" -auto-approve
```

##### Database Recovery

```bash
# Restore from automated backup
aws rds restore-db-cluster-from-snapshot \
  --db-cluster-identifier lecture-$CUSTOMER-cluster-restored \
  --snapshot-identifier automated-snapshot-id \
  --engine aurora-postgresql \
  --profile $AWS_PROFILE
```

## 🔧 Maintenance Procedures

### Regular Maintenance Tasks

#### Weekly Tasks
- [ ] Review CloudWatch alarms and metrics
- [ ] Check for Terraform provider updates
- [ ] Review security group rules
- [ ] Monitor cost optimization opportunities

#### Monthly Tasks
- [ ] Rotate access keys and secrets
- [ ] Review and update documentation
- [ ] Audit user access and permissions
- [ ] Test backup and recovery procedures

#### Quarterly Tasks
- [ ] Security audit and penetration testing
- [ ] Disaster recovery testing
- [ ] Capacity planning review
- [ ] Update incident response procedures

### Maintenance Windows

#### Scheduled Maintenance

```bash
# Pre-maintenance checklist
# 1. Notify customers 48 hours in advance
# 2. Prepare rollback plan
# 3. Backup critical data
# 4. Test procedures in staging

# During maintenance
export CUSTOMER="target-customer"
export AWS_PROFILE="lecture-$CUSTOMER-prod"

# Stop services gracefully
aws ecs update-service \
  --cluster lecture-$CUSTOMER-cluster \
  --service lecture-backend-service \
  --desired-count 0 \
  --profile $AWS_PROFILE

# Perform maintenance tasks
# ...

# Restart services
aws ecs update-service \
  --cluster lecture-$CUSTOMER-cluster \
  --service lecture-backend-service \
  --desired-count 2 \
  --profile $AWS_PROFILE
```

### Backup Procedures

#### Automated Backups

- **RDS**: Automated daily backups (7-day retention)
- **S3**: Cross-region replication enabled
- **Terraform State**: Daily backup to S3
- **ECS Task Definitions**: Versioned automatically

#### Manual Backup

```bash
# Backup Terraform state
aws s3 cp terraform.tfstate s3://terraform-state-backup/lecture-$CUSTOMER/terraform.tfstate.$(date +%Y%m%d)

# Create RDS snapshot
aws rds create-db-cluster-snapshot \
  --db-cluster-snapshot-identifier lecture-$CUSTOMER-manual-$(date +%Y%m%d) \
  --db-cluster-identifier lecture-$CUSTOMER-cluster \
  --profile $AWS_PROFILE
```

## 📞 Escalation Procedures

### When to Escalate

- Issue persists after following runbook procedures
- Security incident detected
- Data loss or corruption suspected
- Customer-facing outage exceeds SLA

### Escalation Contacts

1. **Technical Lead**: For complex technical issues
2. **Security Team**: For security incidents
3. **Management**: For business impact decisions
4. **AWS Support**: For platform-level issues

### Communication Templates

#### Status Update Template

```
Subject: [Incident ID] - Lecture Infrastructure Issue - Status Update

Current Status: [Investigating/Identified/Monitoring/Resolved]
Impact: [Brief description of customer impact]
Next Update: [Time for next update]

Details:
- Issue identified at: [Time]
- Affected customers: [List]
- Current actions: [What we're doing]
- ETA: [Expected resolution time]

Contact: [On-call engineer contact]
```

---

**Last Updated**: 2025-08-22  
**Version**: 2.0  
**On-call Rotation**: Check PagerDuty for current assignments