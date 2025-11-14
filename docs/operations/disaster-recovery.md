<!-- © [2025] EDT&Partners. Licensed under CC BY 4.0. -->
# Disaster Recovery and Backup Procedures

This document outlines the disaster recovery (DR) and backup procedures for the Lecture Infrastructure, ensuring business continuity and data protection across all customer environments.

## 📋 Table of Contents

- [Recovery Objectives](#recovery-objectives)
- [Backup Strategy](#backup-strategy)
- [Disaster Recovery Plan](#disaster-recovery-plan)
- [Recovery Procedures](#recovery-procedures)
- [Testing and Validation](#testing-and-validation)
- [Emergency Contacts](#emergency-contacts)

## 🎯 Recovery Objectives

### Service Level Objectives (SLOs)

| Component | RTO (Recovery Time Objective) | RPO (Recovery Point Objective) | Availability Target |
|-----------|-------------------------------|--------------------------------|-------------------|
| **Web Application** | 4 hours | 1 hour | 99.9% |
| **Database** | 2 hours | 15 minutes | 99.95% |
| **File Storage** | 1 hour | 5 minutes | 99.99% |
| **Authentication** | 1 hour | 30 minutes | 99.9% |
| **API Services** | 2 hours | 30 minutes | 99.9% |

### Business Impact Classification

| Priority | Service | Impact | Recovery Order |
|----------|---------|--------|---------------|
| **P0 - Critical** | Database, Authentication | Complete service outage | 1st |
| **P1 - High** | Core API, File Storage | Major functionality loss | 2nd |
| **P2 - Medium** | Analytics, Reporting | Reduced functionality | 3rd |
| **P3 - Low** | Documentation, Logs | Minimal impact | 4th |

## 💾 Backup Strategy

### Automated Backup Systems

#### 1. Database Backups (RDS Aurora)

```bash
# Automated daily backups with point-in-time recovery
aws rds describe-db-clusters \
  --db-cluster-identifier lecture-${CUSTOMER}-cluster \
  --query 'DBClusters[0].{BackupRetentionPeriod:BackupRetentionPeriod,PreferredBackupWindow:PreferredBackupWindow}'

# Manual snapshot creation
aws rds create-db-cluster-snapshot \
  --db-cluster-snapshot-identifier lecture-${CUSTOMER}-manual-$(date +%Y%m%d-%H%M) \
  --db-cluster-identifier lecture-${CUSTOMER}-cluster
```

**Backup Schedule**:
- **Automated**: Daily at 03:00 UTC
- **Retention**: 30 days for production, 7 days for staging
- **Manual Snapshots**: Before major deployments
- **Cross-Region**: Weekly snapshots to secondary region

#### 2. File Storage Backups (S3)

```bash
# Cross-region replication status
aws s3api get-bucket-replication \
  --bucket content-${CUSTOMER}-prod

# Versioning status
aws s3api get-bucket-versioning \
  --bucket content-${CUSTOMER}-prod

# Lifecycle policies for cost optimization
aws s3api get-bucket-lifecycle-configuration \
  --bucket content-${CUSTOMER}-prod
```

**Backup Features**:
- **Versioning**: Enabled on all production buckets
- **Cross-Region Replication**: To secondary AWS region
- **Lifecycle Policies**: Transition to IA after 30 days, Glacier after 90 days
- **Point-in-Time Recovery**: Through versioning and lifecycle policies

#### 3. Infrastructure Backups (Terraform State)

```bash
# Daily state backup
aws s3 cp terraform.tfstate s3://terraform-state-backup/lecture-${CUSTOMER}/terraform.tfstate.$(date +%Y%m%d)

# State versioning (automatically enabled)
aws s3api get-bucket-versioning \
  --bucket terraform-state-${CUSTOMER}

# State lock backup
aws dynamodb scan \
  --table-name terraform-state-lock \
  --output json > terraform-lock-backup-$(date +%Y%m%d).json
```

**State Protection**:
- **Versioning**: Enabled on state S3 buckets
- **Daily Backups**: Automated state file backups
- **Lock Protection**: DynamoDB table backups
- **Multi-Region**: State replicated to secondary region

#### 4. Container Image Backups (ECR)

```bash
# List ECR repositories
aws ecr describe-repositories \
  --query 'repositories[*].repositoryName'

# Repository lifecycle policies
aws ecr get-lifecycle-policy \
  --repository-name lecture-backend

# Cross-region replication
aws ecr describe-registry \
  --query 'registryPolicy'
```

**Image Protection**:
- **Lifecycle Policies**: Keep 10 latest images, archive older versions
- **Cross-Region Replication**: Critical images replicated to secondary region
- **Vulnerability Scanning**: Automated security scanning enabled

### Backup Monitoring and Alerting

#### CloudWatch Alarms for Backup Failures

```bash
# RDS backup failure alarm
aws cloudwatch put-metric-alarm \
  --alarm-name "RDS-Backup-Failure-${CUSTOMER}" \
  --alarm-description "RDS automated backup failed" \
  --metric-name "DatabaseConnections" \
  --namespace "AWS/RDS" \
  --statistic "Average" \
  --period 86400 \
  --threshold 1 \
  --comparison-operator "LessThanThreshold" \
  --evaluation-periods 1 \
  --alarm-actions "arn:aws:sns:region:account:backup-alerts"

# S3 replication failure alarm
aws cloudwatch put-metric-alarm \
  --alarm-name "S3-Replication-Failure-${CUSTOMER}" \
  --alarm-description "S3 cross-region replication failed" \
  --metric-name "ReplicationLatency" \
  --namespace "AWS/S3" \
  --statistic "Maximum" \
  --period 3600 \
  --threshold 3600 \
  --comparison-operator "GreaterThanThreshold" \
  --evaluation-periods 2
```

## 🚨 Disaster Recovery Plan

### Disaster Scenarios

#### 1. Regional Outage
**Trigger**: AWS region completely unavailable
**Impact**: Complete service outage for affected customers
**Recovery**: Failover to secondary region

#### 2. Availability Zone Outage
**Trigger**: Single AZ unavailable
**Impact**: Reduced capacity, potential service degradation
**Recovery**: Auto-scaling to remaining AZs

#### 3. Data Corruption
**Trigger**: Database or file corruption detected
**Impact**: Data integrity issues
**Recovery**: Restore from clean backup

#### 4. Security Breach
**Trigger**: Confirmed security compromise
**Impact**: Service shutdown for security
**Recovery**: Clean environment rebuild

#### 5. Human Error
**Trigger**: Accidental deletion or misconfiguration
**Impact**: Partial or complete service disruption
**Recovery**: Restore from recent backup

### DR Architecture

```
Primary Region (eu-central-1)         Secondary Region (us-east-1)
┌─────────────────────────────┐      ┌─────────────────────────────┐
│ Production Environment      │      │ DR Environment              │
│                            │      │                            │
│ ┌─────────────────────────┐ │      │ ┌─────────────────────────┐ │
│ │ ECS Cluster (Active)    │ │ ──── │ │ ECS Cluster (Standby)   │ │
│ │ RDS Cluster (Primary)   │ │ ──── │ │ RDS Cluster (Read Replica)│ │
│ │ S3 Buckets (Primary)    │ │ ──── │ │ S3 Buckets (Replica)    │ │
│ │ CloudFront (Primary)    │ │ ──── │ │ CloudFront (Backup)     │ │
│ └─────────────────────────┘ │      │ └─────────────────────────┘ │
└─────────────────────────────┘      └─────────────────────────────┘
```

## 🔄 Recovery Procedures

### Regional Failover (RTO: 4 hours)

#### Step 1: Assessment and Decision (30 minutes)

```bash
# Check regional service status
aws --region eu-central-1 sts get-caller-identity
aws --region us-east-1 sts get-caller-identity

# Verify DR environment status
export DR_REGION="us-east-1"
export PRIMARY_REGION="eu-central-1"
export CUSTOMER="affected-customer"

# Check DR infrastructure readiness
aws --region $DR_REGION ecs describe-clusters \
  --clusters lecture-${CUSTOMER}-dr-cluster

aws --region $DR_REGION rds describe-db-clusters \
  --db-cluster-identifier lecture-${CUSTOMER}-dr-cluster
```

#### Step 2: Database Failover (60 minutes)

```bash
# Promote read replica to primary
aws --region $DR_REGION rds promote-read-replica-db-cluster \
  --db-cluster-identifier lecture-${CUSTOMER}-dr-cluster

# Verify promotion status
aws --region $DR_REGION rds describe-db-clusters \
  --db-cluster-identifier lecture-${CUSTOMER}-dr-cluster \
  --query 'DBClusters[0].Status'

# Update application configuration
kubectl --context dr-cluster set env deployment/lecture-backend \
  DATABASE_HOST=$(aws --region $DR_REGION rds describe-db-clusters \
    --db-cluster-identifier lecture-${CUSTOMER}-dr-cluster \
    --query 'DBClusters[0].Endpoint' --output text)
```

#### Step 3: Application Failover (90 minutes)

```bash
# Scale up DR environment
aws --region $DR_REGION ecs update-service \
  --cluster lecture-${CUSTOMER}-dr-cluster \
  --service lecture-backend-service \
  --desired-count 3

# Verify service health
aws --region $DR_REGION ecs describe-services \
  --cluster lecture-${CUSTOMER}-dr-cluster \
  --services lecture-backend-service

# Update load balancer targets
aws --region $DR_REGION elbv2 modify-target-group \
  --target-group-arn $DR_TARGET_GROUP_ARN \
  --health-check-enabled
```

#### Step 4: DNS and Traffic Routing (60 minutes)

```bash
# Update Route 53 records to point to DR region
aws route53 change-resource-record-sets \
  --hosted-zone-id $HOSTED_ZONE_ID \
  --change-batch file://dr-failover-changeset.json

# Update CloudFront origin
aws cloudfront update-distribution \
  --id $DISTRIBUTION_ID \
  --distribution-config file://dr-distribution-config.json

# Verify DNS propagation
dig +short api.${CUSTOMER}.lecture-platform.com
```

#### Step 5: Verification and Monitoring (30 minutes)

```bash
# Health check endpoints
curl -f https://api.${CUSTOMER}.lecture-platform.com/health
curl -f https://app.${CUSTOMER}.lecture-platform.com/status

# Verify database connectivity
aws --region $DR_REGION rds describe-db-cluster-endpoints \
  --db-cluster-identifier lecture-${CUSTOMER}-dr-cluster

# Enable enhanced monitoring
aws --region $DR_REGION logs create-log-group \
  --log-group-name /aws/ecs/lecture-${CUSTOMER}-dr

# Set up alerting for DR environment
aws --region $DR_REGION cloudwatch put-metric-alarm \
  --alarm-name "DR-Environment-Health-${CUSTOMER}" \
  --alarm-description "DR environment health check" \
  --metric-name "HealthyHostCount" \
  --namespace "AWS/ApplicationELB" \
  --statistic "Average" \
  --period 300 \
  --threshold 1 \
  --comparison-operator "LessThanThreshold" \
  --evaluation-periods 2
```

### Database Recovery from Backup

#### Point-in-Time Recovery

```bash
# Restore database to specific point in time
aws rds restore-db-cluster-to-point-in-time \
  --db-cluster-identifier lecture-${CUSTOMER}-restored \
  --source-db-cluster-identifier lecture-${CUSTOMER}-cluster \
  --restore-to-time 2025-08-22T10:30:00Z \
  --vpc-security-group-ids sg-xxxxxxxxx \
  --db-subnet-group-name lecture-${CUSTOMER}-subnet-group

# Monitor restoration progress
aws rds describe-db-clusters \
  --db-cluster-identifier lecture-${CUSTOMER}-restored \
  --query 'DBClusters[0].Status'

# Once available, update application configuration
export NEW_DB_ENDPOINT=$(aws rds describe-db-clusters \
  --db-cluster-identifier lecture-${CUSTOMER}-restored \
  --query 'DBClusters[0].Endpoint' --output text)

# Update ECS service environment variables
aws ecs update-service \
  --cluster lecture-${CUSTOMER}-cluster \
  --service lecture-backend-service \
  --task-definition lecture-backend:latest
```

#### Snapshot Recovery

```bash
# List available snapshots
aws rds describe-db-cluster-snapshots \
  --db-cluster-identifier lecture-${CUSTOMER}-cluster \
  --snapshot-type automated \
  --query 'DBClusterSnapshots[*].{ID:DBClusterSnapshotIdentifier,Time:SnapshotCreateTime}'

# Restore from specific snapshot
aws rds restore-db-cluster-from-snapshot \
  --db-cluster-identifier lecture-${CUSTOMER}-restored \
  --snapshot-identifier lecture-${CUSTOMER}-cluster-automated-20250822-030000 \
  --engine aurora-postgresql

# Verify cluster status
aws rds describe-db-clusters \
  --db-cluster-identifier lecture-${CUSTOMER}-restored
```

### File Storage Recovery

#### S3 Version Recovery

```bash
# List object versions
aws s3api list-object-versions \
  --bucket content-${CUSTOMER}-prod \
  --prefix "uploads/documents/" \
  --max-items 100

# Restore specific version
aws s3api get-object \
  --bucket content-${CUSTOMER}-prod \
  --key "uploads/documents/important-file.pdf" \
  --version-id "3/L4kqtJlcpXroDVBH40Nr8X8gdRQBpUMLUo" \
  --output-file restored-file.pdf

# Bulk restore from cross-region replica
aws s3 sync s3://content-${CUSTOMER}-prod-replica/ s3://content-${CUSTOMER}-prod/ \
  --exclude "*" \
  --include "uploads/documents/*" \
  --source-region us-east-1
```

## 🧪 Testing and Validation

### DR Testing Schedule

#### Monthly Tests
- [ ] **Backup Verification**: Test restore from automated backups
- [ ] **Failover Simulation**: Practice database read replica promotion
- [ ] **Documentation Review**: Update procedures and contact information

#### Quarterly Tests  
- [ ] **Full DR Exercise**: Complete regional failover simulation
- [ ] **Cross-Team Coordination**: Test communication and escalation procedures
- [ ] **Performance Validation**: Verify DR environment performance meets SLOs

#### Annual Tests
- [ ] **Comprehensive DR Test**: Full disaster simulation with customer impact assessment
- [ ] **Business Continuity Review**: Evaluate and update business continuity plans
- [ ] **Third-Party Coordination**: Test with external vendors and partners

### Testing Procedures

#### Database Backup Test

```bash
#!/bin/bash
# Monthly database backup test script

CUSTOMER=$1
TEST_CLUSTER="lecture-${CUSTOMER}-test-restore"

echo "Starting database backup test for ${CUSTOMER}..."

# Create test restore from latest automated backup
aws rds restore-db-cluster-to-point-in-time \
  --db-cluster-identifier $TEST_CLUSTER \
  --source-db-cluster-identifier lecture-${CUSTOMER}-cluster \
  --restore-to-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%SZ) \
  --vpc-security-group-ids sg-test-restore \
  --db-subnet-group-name lecture-${CUSTOMER}-subnet-group

# Wait for cluster to be available
aws rds wait db-cluster-available --db-cluster-identifier $TEST_CLUSTER

# Verify data integrity
ENDPOINT=$(aws rds describe-db-clusters \
  --db-cluster-identifier $TEST_CLUSTER \
  --query 'DBClusters[0].Endpoint' --output text)

# Connect and run basic queries
psql -h $ENDPOINT -U postgres -d lecture -c "SELECT COUNT(*) FROM users;"
psql -h $ENDPOINT -U postgres -d lecture -c "SELECT COUNT(*) FROM courses;"

# Cleanup test resources
aws rds delete-db-cluster \
  --db-cluster-identifier $TEST_CLUSTER \
  --skip-final-snapshot

echo "Database backup test completed successfully."
```

#### Application Failover Test

```bash
#!/bin/bash
# Quarterly application failover test script

CUSTOMER=$1
DR_REGION="us-east-1"

echo "Starting application failover test for ${CUSTOMER}..."

# Scale down primary region services
aws ecs update-service \
  --cluster lecture-${CUSTOMER}-cluster \
  --service lecture-backend-service \
  --desired-count 0

# Scale up DR region services
aws --region $DR_REGION ecs update-service \
  --cluster lecture-${CUSTOMER}-dr-cluster \
  --service lecture-backend-service \
  --desired-count 2

# Update Route 53 for testing
aws route53 change-resource-record-sets \
  --hosted-zone-id $HOSTED_ZONE_ID \
  --change-batch file://dr-test-changeset.json

# Wait for services to be stable
aws --region $DR_REGION ecs wait services-stable \
  --cluster lecture-${CUSTOMER}-dr-cluster \
  --services lecture-backend-service

# Run health checks
curl -f https://api.${CUSTOMER}.lecture-platform.com/health

# Rollback changes
aws route53 change-resource-record-sets \
  --hosted-zone-id $HOSTED_ZONE_ID \
  --change-batch file://primary-region-changeset.json

aws ecs update-service \
  --cluster lecture-${CUSTOMER}-cluster \
  --service lecture-backend-service \
  --desired-count 2

aws --region $DR_REGION ecs update-service \
  --cluster lecture-${CUSTOMER}-dr-cluster \
  --service lecture-backend-service \
  --desired-count 0

echo "Application failover test completed successfully."
```

## 🚑 Emergency Contacts

### Internal DR Team

| Role | Primary | Backup | Phone | Email |
|------|---------|---------|-------|-------|
| **DR Coordinator** | [Name] | [Name] | +1-XXX-XXX-XXXX | dr-lead@company.com |
| **Database Administrator** | [Name] | [Name] | +1-XXX-XXX-XXXX | dba@company.com |
| **Infrastructure Lead** | [Name] | [Name] | +1-XXX-XXX-XXXX | infra-lead@company.com |
| **Security Officer** | [Name] | [Name] | +1-XXX-XXX-XXXX | security@company.com |

### External Contacts

- **AWS Enterprise Support**: 1-800-SUPPORT (Premium Support)
- **Legal Counsel**: [External firm] - +1-XXX-XXX-XXXX
- **Insurance Provider**: [Cyber insurance] - +1-XXX-XXX-XXXX
- **Public Relations**: [PR firm] - +1-XXX-XXX-XXXX

### Escalation Matrix

```
Disaster Detected → DR Coordinator → Infrastructure Team
                 → Database Team → Security Team
                 → Management → Legal/PR (if needed)
```

### Communication Channels

- **Primary**: Slack #incident-response
- **Secondary**: Microsoft Teams Incident Room
- **Tertiary**: Phone conference bridge: +1-XXX-XXX-XXXX
- **Customer Communication**: Status page + direct notification

## 📊 Metrics and Reporting

### DR Metrics Dashboard

#### Key Performance Indicators
- **RTO Actual vs Target**: Track actual recovery times against objectives
- **RPO Actual vs Target**: Measure data loss in actual incidents
- **Backup Success Rate**: Percentage of successful automated backups
- **Test Success Rate**: Percentage of successful DR tests
- **Mean Time to Recovery (MTTR)**: Average time to restore services

#### Monthly DR Report Template

```
# Disaster Recovery Monthly Report - [Month] [Year]

## Executive Summary
- Total incidents: X
- Services affected: [List]
- Average RTO: X hours (Target: Y hours)
- Average RPO: X minutes (Target: Y minutes)

## Backup Status
- Database backups: 100% success rate
- File storage backups: 100% success rate
- Infrastructure backups: 100% success rate

## Testing Activities
- Tests conducted: X
- Tests passed: X
- Issues identified: X
- Improvements implemented: X

## Action Items
1. [Action item 1]
2. [Action item 2]
3. [Action item 3]

## Recommendations
- [Recommendation 1]
- [Recommendation 2]
```

---

**Last Updated**: 2025-08-22  
**Version**: 2.0  
**Next Review**: 2025-11-22  
**Owner**: Infrastructure Team