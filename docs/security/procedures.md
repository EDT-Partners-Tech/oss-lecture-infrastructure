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

# Security Procedures and Incident Response

This document outlines security procedures, incident response protocols, and security best practices for the Lecture Infrastructure project.

## 📋 Table of Contents

- [Security Framework](#security-framework)
- [Access Management](#access-management)
- [Incident Response](#incident-response)
- [Security Monitoring](#security-monitoring)
- [Compliance](#compliance)
- [Security Controls](#security-controls)
- [Emergency Procedures](#emergency-procedures)

## 🛡️ Security Framework

### Security Principles

1. **Zero Trust**: Never trust, always verify
2. **Least Privilege**: Minimum necessary access
3. **Defense in Depth**: Multiple security layers
4. **Continuous Monitoring**: Real-time threat detection
5. **Incident Response**: Rapid containment and recovery

### Security Responsibilities

| Role | Responsibilities |
|------|------------------|
| **CISO** | Overall security strategy and governance |
| **Security Team** | Security monitoring, incident response, compliance |
| **DevOps Team** | Infrastructure security, secure deployments |
| **Development Team** | Secure coding, vulnerability remediation |
| **Operations Team** | Security monitoring, access management |

### Security Classifications

| Level | Description | Examples | Controls |
|-------|-------------|----------|----------|
| **Public** | Information intended for public access | Marketing materials, public documentation | Basic access controls |
| **Internal** | Information for internal use | Internal documentation, policies | Authentication required |
| **Confidential** | Sensitive business information | Customer data, financial information | Encryption, access logging |
| **Restricted** | Highly sensitive information | Security credentials, PII | Strong encryption, MFA, audit trails |

## 🔐 Access Management

### User Access Lifecycle

#### 1. Access Provisioning

```bash
# New team member onboarding
# 1. Create AWS IAM user with temporary credentials
aws iam create-user --user-name john.doe

# 2. Add to appropriate groups based on role
aws iam add-user-to-group --user-name john.doe --group-name developers

# 3. Force password change on first login
aws iam create-login-profile --user-name john.doe --password TempPassword123! --password-reset-required

# 4. Enable MFA requirement
aws iam put-user-policy --user-name john.doe --policy-name RequireMFA --policy-document file://require-mfa-policy.json
```

#### 2. Access Reviews

**Monthly Reviews**:
- Review all active user accounts
- Verify role assignments
- Check for unused permissions
- Audit privileged access

**Quarterly Reviews**:
- Full access certification
- Remove inactive accounts
- Update role definitions
- Review emergency access

#### 3. Access Revocation

```bash
# Employee departure checklist
# 1. Disable IAM user
aws iam delete-login-profile --user-name departing.user

# 2. Remove from all groups
aws iam get-groups-for-user --user-name departing.user
aws iam remove-user-from-group --user-name departing.user --group-name group-name

# 3. Delete access keys
aws iam list-access-keys --user-name departing.user
aws iam delete-access-key --user-name departing.user --access-key-id AKIAXXXXXXXXXXXXXXXX

# 4. Remove from external systems
# - GitHub repositories
# - AWS Console access
# - VPN access
# - Monitoring systems
```

### Privileged Access Management

#### Emergency Access

```bash
# Emergency break-glass access procedure
# 1. Log emergency access request
echo "$(date): Emergency access requested by $(whoami) for incident ${INCIDENT_ID}" >> /var/log/emergency-access.log

# 2. Use emergency credentials (stored in secure vault)
export AWS_PROFILE=emergency-access

# 3. Document all actions taken
aws cloudtrail lookup-events --lookup-attributes AttributeKey=Username,AttributeValue=emergency-user

# 4. Revoke access immediately after incident resolution
```

#### Service Accounts

```hcl
# Terraform service account with minimal permissions
resource "aws_iam_user" "terraform_service" {
  name = "terraform-deployment-service"
  path = "/service-accounts/"
  
  tags = {
    Purpose = "Terraform deployment automation"
    Type    = "ServiceAccount"
  }
}

resource "aws_iam_user_policy_attachment" "terraform_service" {
  user       = aws_iam_user.terraform_service.name
  policy_arn = aws_iam_policy.terraform_deployment.arn
}

# Rotate access keys every 90 days
resource "aws_iam_access_key" "terraform_service" {
  user = aws_iam_user.terraform_service.name
  
  lifecycle {
    ignore_changes = [
      # Prevent accidental key rotation during normal deployments
      # Keys should be rotated through scheduled process
    ]
  }
}
```

## 🚨 Incident Response

### Incident Classification

| Severity | Description | Response Time | Examples |
|----------|-------------|---------------|----------|
| **P0 - Critical** | Immediate threat to operations | 15 minutes | Active breach, data exfiltration |
| **P1 - High** | Significant security risk | 1 hour | Suspicious activity, failed controls |
| **P2 - Medium** | Potential security issue | 4 hours | Policy violations, minor vulnerabilities |
| **P3 - Low** | Security concern | 24 hours | Documentation issues, process gaps |

### Incident Response Process

#### 1. Detection and Analysis (0-30 minutes)

```bash
# Initial detection workflow
# 1. Alert received from monitoring system
# 2. Initial triage and classification

# Check system status
./scripts/security-status-check.sh

# Gather initial evidence
aws cloudtrail lookup-events \
  --start-time $(date -d '1 hour ago' --iso-8601) \
  --end-time $(date --iso-8601) \
  --lookup-attributes AttributeKey=EventName,AttributeValue=AssumeRole

# Check for indicators of compromise
aws guardduty list-findings --detector-id $GUARDDUTY_DETECTOR_ID
```

#### 2. Containment (30-60 minutes)

```bash
# Immediate containment procedures
# 1. Isolate affected systems
aws ec2 modify-instance-attribute \
  --instance-id $COMPROMISED_INSTANCE \
  --groups sg-isolated

# 2. Revoke suspicious access
aws iam delete-access-key \
  --user-name $SUSPICIOUS_USER \
  --access-key-id $ACCESS_KEY_ID

# 3. Enable additional logging
aws cloudtrail put-event-selectors \
  --trail-name $TRAIL_NAME \
  --event-selectors ReadWriteType=All,IncludeManagementEvents=true

# 4. Create forensic snapshots
aws ec2 create-snapshot \
  --volume-id $AFFECTED_VOLUME \
  --description "Forensic snapshot for incident $INCIDENT_ID"
```

#### 3. Investigation (1-4 hours)

```bash
# Detailed investigation procedures
# 1. Analyze CloudTrail logs
aws logs filter-log-events \
  --log-group-name CloudTrail/SecurityEvents \
  --start-time $(date -d '24 hours ago' +%s)000 \
  --filter-pattern "ERROR"

# 2. Check VPC Flow Logs
aws logs filter-log-events \
  --log-group-name VPCFlowLogs \
  --start-time $(date -d '4 hours ago' +%s)000 \
  --filter-pattern "REJECT"

# 3. Analyze application logs
aws logs filter-log-events \
  --log-group-name /ecs/lecture-backend \
  --start-time $(date -d '4 hours ago' +%s)000 \
  --filter-pattern "authentication failure"
```

#### 4. Recovery and Post-Incident

```bash
# Recovery procedures
# 1. Apply security patches
terraform apply -var-file="security-patches.tfvars"

# 2. Restore from clean backups if needed
aws rds restore-db-cluster-from-snapshot \
  --db-cluster-identifier restored-cluster \
  --snapshot-identifier clean-snapshot-id

# 3. Update security configurations
aws s3api put-bucket-policy \
  --bucket $BUCKET_NAME \
  --policy file://updated-bucket-policy.json

# 4. Verify system integrity
./scripts/security-verification.sh
```

### Communication Procedures

#### Internal Communication

```markdown
# Incident Report Template

**Incident ID**: INC-2025-001
**Severity**: P1 - High
**Status**: Investigating
**Incident Commander**: [Name]

## Summary
Brief description of the incident and impact.

## Timeline
- 14:00 UTC: Initial detection
- 14:15 UTC: Incident declared
- 14:30 UTC: Containment measures applied

## Impact
- Affected systems: [List]
- Customer impact: [Description]
- Data exposure: [Assessment]

## Actions Taken
1. Isolated affected systems
2. Revoked suspicious access
3. Enabled additional monitoring

## Next Steps
1. Continue investigation
2. Apply security patches
3. Prepare customer communication

## Contact
- Incident Commander: [Contact]
- Security Team: security@company.com
```

#### External Communication

```markdown
# Customer Notification Template

Subject: Security Incident Notification - [Customer Name]

Dear [Customer Name],

We are writing to inform you of a security incident that may have affected your data in our lecture platform.

**What Happened:**
[Brief description of the incident]

**What Information Was Involved:**
[Description of potentially affected data]

**What We Are Doing:**
[Actions taken to address the incident]

**What You Can Do:**
[Recommended actions for the customer]

We sincerely apologize for this incident and any inconvenience it may cause. If you have any questions, please contact us at security@company.com.

Sincerely,
Security Team
```

## 📊 Security Monitoring

### Key Security Metrics

#### Authentication and Access
- Failed login attempts
- Privileged access usage
- MFA bypass attempts
- Unusual access patterns

#### Network Security
- Suspicious network connections
- DDoS attack patterns
- Port scanning attempts
- Data exfiltration indicators

#### Application Security
- SQL injection attempts
- XSS attack patterns
- API abuse indicators
- Input validation failures

### Monitoring Tools Configuration

#### CloudWatch Alarms

```bash
# High-priority security alarms
aws cloudwatch put-metric-alarm \
  --alarm-name "Multiple-Failed-Logins" \
  --alarm-description "Multiple failed login attempts detected" \
  --metric-name "FailedLoginAttempts" \
  --namespace "Custom/Security" \
  --statistic Sum \
  --period 300 \
  --threshold 10 \
  --comparison-operator GreaterThanThreshold \
  --evaluation-periods 1 \
  --alarm-actions arn:aws:sns:region:account:security-alerts

# Unusual API activity
aws cloudwatch put-metric-alarm \
  --alarm-name "Unusual-API-Activity" \
  --alarm-description "Unusual API call patterns detected" \
  --metric-name "APICallCount" \
  --namespace "AWS/CloudTrail" \
  --statistic Sum \
  --period 3600 \
  --threshold 1000 \
  --comparison-operator GreaterThanThreshold \
  --evaluation-periods 1
```

#### GuardDuty Configuration

```bash
# Enable GuardDuty
aws guardduty create-detector \
  --enable \
  --finding-publishing-frequency FIFTEEN_MINUTES

# Configure threat intelligence feeds
aws guardduty create-threat-intel-set \
  --detector-id $DETECTOR_ID \
  --name "Custom-Threat-Intel" \
  --format TXT \
  --location s3://threat-intel-bucket/indicators.txt \
  --activate
```

## 📋 Compliance

### Regulatory Requirements

#### Data Protection (GDPR)
- Data minimization
- Consent management
- Right to erasure
- Data breach notification
- Privacy by design

#### Security Frameworks
- **ISO 27001**: Information security management
- **SOC 2**: Security, availability, processing integrity
- **NIST CSF**: Cybersecurity framework
- **CIS Controls**: Critical security controls

### Compliance Monitoring

```bash
# Automated compliance checks
# 1. Check encryption status
aws rds describe-db-clusters \
  --query 'DBClusters[?StorageEncrypted==`false`]'

# 2. Verify backup configurations
aws rds describe-db-clusters \
  --query 'DBClusters[?BackupRetentionPeriod<`7`]'

# 3. Check public access
aws s3api list-buckets \
  --query 'Buckets[*].Name' \
  --output text | xargs -I {} aws s3api get-bucket-acl --bucket {}

# 4. Audit user permissions
aws iam generate-credential-report
aws iam get-credential-report
```

## 🔒 Security Controls

### Technical Controls

#### Network Security

```hcl
# Web Application Firewall
resource "aws_wafv2_web_acl" "main" {
  name  = "${var.project}-${var.environment}-waf"
  scope = "CLOUDFRONT"
  
  default_action {
    allow {}
  }
  
  # Rate limiting rule
  rule {
    name     = "RateLimitRule"
    priority = 1
    
    action {
      block {}
    }
    
    statement {
      rate_based_statement {
        limit              = 2000
        aggregate_key_type = "IP"
      }
    }
    
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "RateLimitRule"
      sampled_requests_enabled   = true
    }
  }
  
  # SQL injection protection
  rule {
    name     = "SQLInjectionRule"
    priority = 2
    
    action {
      block {}
    }
    
    statement {
      sqli_match_statement {
        field_to_match {
          body {}
        }
        text_transformation {
          priority = 0
          type     = "URL_DECODE"
        }
      }
    }
    
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "SQLInjectionRule"
      sampled_requests_enabled   = true
    }
  }
}
```

#### Encryption

```hcl
# KMS key for data encryption
resource "aws_kms_key" "main" {
  description             = "Main encryption key for ${var.project}"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow use of the key"
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.service_role.arn
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })
  
  tags = {
    Name = "${var.project}-${var.environment}-main-key"
  }
}
```

### Administrative Controls

#### Security Policies

1. **Password Policy**: Minimum 12 characters, complexity requirements
2. **MFA Policy**: Required for all privileged access
3. **Access Review Policy**: Quarterly access certifications
4. **Data Classification Policy**: Classification and handling procedures
5. **Incident Response Policy**: Response procedures and escalation

#### Security Training

- **Onboarding**: Security awareness for new employees
- **Annual Training**: Updated security training for all staff
- **Role-Specific Training**: Specialized training for technical roles
- **Phishing Simulation**: Regular phishing awareness testing

## 🚑 Emergency Procedures

### Security Emergency Response

#### 1. Immediate Response (0-15 minutes)

```bash
#!/bin/bash
# Emergency security response script

# 1. Alert security team
curl -X POST -H 'Content-type: application/json' \
  --data '{"text":"SECURITY EMERGENCY: Incident detected - immediate response required"}' \
  $SECURITY_SLACK_WEBHOOK

# 2. Enable emergency logging
aws cloudtrail put-event-selectors \
  --trail-name EmergencyTrail \
  --event-selectors ReadWriteType=All,IncludeManagementEvents=true

# 3. Take system snapshot
aws ec2 create-snapshot \
  --volume-id $CRITICAL_VOLUME \
  --description "Emergency snapshot $(date)"

# 4. Enable GuardDuty if not already active
aws guardduty create-detector --enable
```

#### 2. Containment Procedures

```bash
# Network isolation
aws ec2 modify-instance-attribute \
  --instance-id $INSTANCE_ID \
  --groups sg-emergency-isolation

# Disable compromised users
aws iam attach-user-policy \
  --user-name $COMPROMISED_USER \
  --policy-arn arn:aws:iam::aws:policy/AWSDenyAll

# Rotate all access keys
aws iam list-users --query 'Users[*].UserName' --output text | \
  xargs -I {} aws iam list-access-keys --user-name {} --output text
```

### Data Breach Response

1. **Immediate Actions**:
   - Stop data exfiltration
   - Preserve evidence
   - Assess scope and impact
   - Notify incident commander

2. **Assessment**:
   - Identify affected data
   - Determine root cause
   - Estimate customer impact
   - Calculate regulatory obligations

3. **Notification**:
   - Internal stakeholders (immediate)
   - Regulatory authorities (72 hours)
   - Affected customers (without undue delay)
   - Public disclosure (if required)

4. **Recovery**:
   - Implement fixes
   - Verify security measures
   - Monitor for further issues
   - Document lessons learned

## 📞 Emergency Contacts

### Internal Contacts

| Role | Primary | Backup | Contact Method |
|------|---------|---------|----------------|
| **CISO** | [Name] | [Name] | Phone + Slack |
| **Security Team Lead** | [Name] | [Name] | Phone + Slack |
| **DevOps Lead** | [Name] | [Name] | Slack + Email |
| **Legal Counsel** | [Name] | [Name] | Phone + Email |

### External Contacts

- **AWS Support**: Enterprise Support Portal
- **Legal Counsel**: [External firm contact]
- **Cyber Insurance**: [Insurance company contact]
- **Law Enforcement**: [Local cyber crime unit]

### Escalation Matrix

```
P0 Incident → Security Team → CISO → CEO
            → Legal Team → External Counsel
            → PR Team → Public Relations
```

---

**Last Updated**: 2025-08-22  
**Version**: 2.0  
**Classification**: Confidential  
**Next Review**: 2025-11-22