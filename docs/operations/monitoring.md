<!-- © [2025] EDT&Partners. Licensed under CC BY 4.0. -->
# Monitoring and Alerting Setup

This document outlines the comprehensive monitoring and alerting strategy for the Lecture Infrastructure, providing observability across all customer environments and infrastructure components.

## 📋 Table of Contents

- [Monitoring Architecture](#monitoring-architecture)
- [Metrics and KPIs](#metrics-and-kpis)
- [Alerting Strategy](#alerting-strategy)
- [Dashboard Configuration](#dashboard-configuration)
- [Log Management](#log-management)
- [Performance Monitoring](#performance-monitoring)
- [Cost Monitoring](#cost-monitoring)

## 🏗️ Monitoring Architecture

### Observability Stack

```
┌─────────────────────────────────────────────────────────────┐
│                    Monitoring Overview                      │
├─────────────────────────────────────────────────────────────┤
│ Data Collection Layer                                       │
│ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐            │
│ │ CloudWatch  │ │   VPC Flow  │ │ Application │            │
│ │   Metrics   │ │    Logs     │ │    Logs     │            │
│ └─────────────┘ └─────────────┘ └─────────────┘            │
├─────────────────────────────────────────────────────────────┤
│ Processing and Analysis Layer                               │
│ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐            │
│ │   Athena    │ │ CloudWatch  │ │    X-Ray    │            │
│ │ Analytics   │ │  Insights   │ │   Tracing   │            │
│ └─────────────┘ └─────────────┘ └─────────────┘            │
├─────────────────────────────────────────────────────────────┤
│ Visualization and Alerting Layer                           │
│ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐            │
│ │ CloudWatch  │ │     SNS     │ │    Slack    │            │
│ │ Dashboards  │ │   Alerts    │ │Integration  │            │
│ └─────────────┘ └─────────────┘ └─────────────┘            │
└─────────────────────────────────────────────────────────────┘
```

### Multi-Customer Monitoring Strategy

```
Customer A (DHBW)          Customer B (EDT)           Customer C (Unilux)
┌─────────────────┐       ┌─────────────────┐       ┌─────────────────┐
│ Regional Metrics│       │ Regional Metrics│       │ Regional Metrics│
│ eu-central-1    │       │   us-east-1     │       │ eu-central-1    │
└─────────────────┘       └─────────────────┘       └─────────────────┘
         │                         │                         │
         └─────────────────────────┼─────────────────────────┘
                                   │
                          ┌─────────────────┐
                          │ Centralized     │
                          │ Monitoring      │
                          │ Dashboard       │
                          └─────────────────┘
```

## 📊 Metrics and KPIs

### Infrastructure Metrics

#### Compute Resources (ECS/Lambda)

| Metric | Threshold | Alert Level | Description |
|--------|-----------|-------------|-------------|
| CPU Utilization | >80% for 10 min | Warning | High CPU usage |
| Memory Utilization | >85% for 5 min | Warning | High memory usage |
| Task Count | <1 for 5 min | Critical | No running tasks |
| Lambda Errors | >5% error rate | Warning | Function failures |
| Lambda Duration | >90% of timeout | Warning | Performance degradation |

```bash
# CloudWatch metrics for ECS monitoring
aws cloudwatch put-metric-alarm \
  --alarm-name "ECS-CPU-High-${CUSTOMER}" \
  --alarm-description "ECS CPU utilization is high" \
  --metric-name CPUUtilization \
  --namespace AWS/ECS \
  --statistic Average \
  --period 300 \
  --threshold 80 \
  --comparison-operator GreaterThanThreshold \
  --evaluation-periods 2 \
  --alarm-actions arn:aws:sns:region:account:infrastructure-alerts \
  --dimensions Name=ServiceName,Value=lecture-backend-service \
               Name=ClusterName,Value=lecture-${CUSTOMER}-cluster
```

#### Database Performance (RDS Aurora)

| Metric | Threshold | Alert Level | Description |
|--------|-----------|-------------|-------------|
| CPU Utilization | >70% for 15 min | Warning | Database CPU stress |
| Database Connections | >80% of max | Warning | Connection pool exhaustion |
| Read/Write Latency | >100ms average | Warning | Performance degradation |
| Failed Connections | >10 per minute | Critical | Connection failures |
| Storage Space | >90% used | Critical | Storage running low |

```bash
# Database monitoring setup
aws cloudwatch put-metric-alarm \
  --alarm-name "RDS-CPU-High-${CUSTOMER}" \
  --alarm-description "RDS CPU utilization is high" \
  --metric-name CPUUtilization \
  --namespace AWS/RDS \
  --statistic Average \
  --period 300 \
  --threshold 70 \
  --comparison-operator GreaterThanThreshold \
  --evaluation-periods 3 \
  --alarm-actions arn:aws:sns:region:account:database-alerts \
  --dimensions Name=DBClusterIdentifier,Value=lecture-${CUSTOMER}-cluster
```

#### Storage and Network (S3/CloudFront)

| Metric | Threshold | Alert Level | Description |
|--------|-----------|-------------|-------------|
| S3 4xx Errors | >1% of requests | Warning | Client errors |
| S3 5xx Errors | >0.1% of requests | Critical | Server errors |
| CloudFront 4xx Errors | >5% of requests | Warning | Client errors |
| CloudFront 5xx Errors | >1% of requests | Critical | Server errors |
| CloudFront Cache Hit Ratio | <80% | Warning | Poor caching performance |

### Application Metrics

#### API Performance

| Metric | Threshold | Alert Level | Description |
|--------|-----------|-------------|-------------|
| Response Time | >2s average | Warning | API latency high |
| Error Rate | >5% | Critical | High error rate |
| Request Rate | >1000 req/min | Info | High traffic |
| Authentication Failures | >10 per minute | Warning | Security concern |

#### User Experience

| Metric | Threshold | Alert Level | Description |
|--------|-----------|-------------|-------------|
| Page Load Time | >3s | Warning | Poor user experience |
| Session Duration | <1 minute avg | Warning | User engagement low |
| Bounce Rate | >60% | Warning | User retention issue |
| Error Pages | >2% of pageviews | Warning | Application errors |

### Business Metrics

#### Customer Usage

| Metric | Threshold | Alert Level | Description |
|--------|-----------|-------------|-------------|
| Active Users | <50% of baseline | Warning | Low engagement |
| Content Uploads | <10% of baseline | Warning | Reduced activity |
| API Calls | <20% of baseline | Critical | Service degradation |
| New Registrations | <5 per day | Info | Growth tracking |

## 🚨 Alerting Strategy

### Alert Severity Levels

#### Critical (P0)
- **Response Time**: 15 minutes
- **Conditions**: Service completely down, data loss, security breach
- **Notification**: Phone, SMS, Slack, Email
- **Escalation**: Immediate escalation to on-call engineer

#### High (P1) 
- **Response Time**: 1 hour
- **Conditions**: Significant performance degradation, partial outage
- **Notification**: Slack, Email
- **Escalation**: Escalate after 30 minutes if not acknowledged

#### Medium (P2)
- **Response Time**: 4 hours
- **Conditions**: Minor performance issues, non-critical errors
- **Notification**: Slack, Email
- **Escalation**: Escalate during business hours only

#### Low (P3)
- **Response Time**: Next business day
- **Conditions**: Informational alerts, capacity planning
- **Notification**: Email
- **Escalation**: No automatic escalation

### SNS Topic Configuration

```bash
# Create SNS topics for different alert levels
aws sns create-topic --name lecture-alerts-critical
aws sns create-topic --name lecture-alerts-warning
aws sns create-topic --name lecture-alerts-info

# Subscribe to topics
aws sns subscribe \
  --topic-arn arn:aws:sns:region:account:lecture-alerts-critical \
  --protocol email \
  --notification-endpoint oncall@company.com

aws sns subscribe \
  --topic-arn arn:aws:sns:region:account:lecture-alerts-critical \
  --protocol sms \
  --notification-endpoint +1234567890
```

### Slack Integration

```python
# Lambda function for Slack notifications
import json
import urllib3

def lambda_handler(event, context):
    http = urllib3.PoolManager()
    
    # Parse SNS message
    message = json.loads(event['Records'][0]['Sns']['Message'])
    
    # Determine alert color based on alarm state
    color = 'danger' if message['NewStateValue'] == 'ALARM' else 'good'
    
    slack_message = {
        'text': f"🚨 Alert: {message['AlarmName']}",
        'attachments': [
            {
                'color': color,
                'fields': [
                    {
                        'title': 'Status',
                        'value': message['NewStateValue'],
                        'short': True
                    },
                    {
                        'title': 'Reason',
                        'value': message['NewStateReason'],
                        'short': False
                    }
                ]
            }
        ]
    }
    
    encoded_msg = json.dumps(slack_message).encode('utf-8')
    resp = http.request('POST', SLACK_WEBHOOK_URL, body=encoded_msg)
    
    return {'statusCode': 200}
```

## 📈 Dashboard Configuration

### Executive Dashboard

```json
{
  "widgets": [
    {
      "type": "metric",
      "properties": {
        "metrics": [
          ["AWS/ECS", "CPUUtilization", "ServiceName", "lecture-backend-service"],
          ["AWS/RDS", "CPUUtilization", "DBClusterIdentifier", "lecture-cluster"],
          ["AWS/Lambda", "Duration", "FunctionName", "lecture-processor"]
        ],
        "period": 300,
        "stat": "Average",
        "region": "eu-central-1",
        "title": "Infrastructure Health"
      }
    },
    {
      "type": "metric",
      "properties": {
        "metrics": [
          ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", "lecture-alb"],
          ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", "lecture-alb"]
        ],
        "period": 300,
        "stat": "Sum",
        "region": "eu-central-1",
        "title": "Application Performance"
      }
    }
  ]
}
```

### Operational Dashboard

```bash
# Create operational dashboard
aws cloudwatch put-dashboard \
  --dashboard-name "Lecture-Infrastructure-Operations" \
  --dashboard-body file://operational-dashboard.json

# Dashboard includes:
# - Service health status
# - Error rates and response times
# - Resource utilization
# - Alert status summary
```

### Customer-Specific Dashboards

```bash
# Create customer-specific dashboard
for customer in dhbw edt unilux gva santillana educaria ufv edtufv; do
  aws cloudwatch put-dashboard \
    --dashboard-name "Lecture-${customer}-Overview" \
    --dashboard-body "$(cat customer-dashboard-template.json | sed "s/\${CUSTOMER}/${customer}/g")"
done
```

## 📝 Log Management

### Log Collection Strategy

#### Application Logs
```bash
# ECS log configuration
aws logs create-log-group --log-group-name /ecs/lecture-${CUSTOMER}-backend
aws logs create-log-group --log-group-name /ecs/lecture-${CUSTOMER}-frontend

# Log retention policy
aws logs put-retention-policy \
  --log-group-name /ecs/lecture-${CUSTOMER}-backend \
  --retention-in-days 30
```

#### Infrastructure Logs
```bash
# VPC Flow Logs
aws ec2 create-flow-logs \
  --resource-type VPC \
  --resource-ids vpc-xxxxxxxxx \
  --traffic-type ALL \
  --log-destination-type cloud-watch-logs \
  --log-group-name /aws/vpc/flowlogs

# CloudTrail logging
aws cloudtrail create-trail \
  --name lecture-${CUSTOMER}-audit-trail \
  --s3-bucket-name lecture-${CUSTOMER}-audit-logs \
  --include-global-service-events \
  --is-multi-region-trail
```

### Log Analysis

#### CloudWatch Insights Queries

```sql
-- Find application errors
fields @timestamp, @message
| filter @message like /ERROR/
| sort @timestamp desc
| limit 100

-- Analyze API response times
fields @timestamp, @duration
| filter @message like /API_RESPONSE/
| stats avg(@duration), max(@duration), min(@duration) by bin(5m)

-- Security events analysis
fields @timestamp, @message
| filter @message like /AUTHENTICATION_FAILED/
| stats count() by sourceIP
| sort count desc
```

#### Automated Log Processing

```python
# Lambda function for log processing
import json
import gzip
import base64

def lambda_handler(event, context):
    # Decode CloudWatch Logs data
    cw_data = event['awslogs']['data']
    cw_logs = json.loads(gzip.decompress(base64.b64decode(cw_data)))
    
    for log_event in cw_logs['logEvents']:
        message = log_event['message']
        
        # Parse application logs
        if 'ERROR' in message:
            # Send to security monitoring
            process_error_log(log_event)
        elif 'SLOW_QUERY' in message:
            # Send to performance monitoring
            process_performance_log(log_event)
    
    return {'statusCode': 200}
```

## ⚡ Performance Monitoring

### Application Performance Monitoring (APM)

#### X-Ray Tracing Setup

```bash
# Enable X-Ray tracing for Lambda functions
aws lambda update-function-configuration \
  --function-name lecture-${CUSTOMER}-processor \
  --tracing-config Mode=Active

# Enable X-Ray for API Gateway
aws apigateway put-rest-api \
  --rest-api-id $API_ID \
  --mode overwrite \
  --body '{
    "swagger": "2.0",
    "x-amazon-apigateway-request-validators": {
      "all": {
        "validateRequestBody": true,
        "validateRequestParameters": true
      }
    }
  }'
```

#### Performance Metrics Collection

```python
# Custom metrics for application performance
import boto3

cloudwatch = boto3.client('cloudwatch')

def publish_custom_metric(metric_name, value, unit='Count'):
    cloudwatch.put_metric_data(
        Namespace='Lecture/Application',
        MetricData=[
            {
                'MetricName': metric_name,
                'Value': value,
                'Unit': unit,
                'Dimensions': [
                    {
                        'Name': 'Customer',
                        'Value': CUSTOMER_NAME
                    }
                ]
            }
        ]
    )

# Usage examples
publish_custom_metric('UserLogin', 1)
publish_custom_metric('FileUpload', file_size, 'Bytes')
publish_custom_metric('DatabaseQueryTime', query_duration, 'Milliseconds')
```

### Database Performance Monitoring

#### Performance Insights

```bash
# Enable Performance Insights for RDS
aws rds modify-db-cluster \
  --db-cluster-identifier lecture-${CUSTOMER}-cluster \
  --enable-performance-insights \
  --performance-insights-retention-period 7

# Create custom metrics for database performance
aws cloudwatch put-metric-alarm \
  --alarm-name "DB-ReadLatency-High-${CUSTOMER}" \
  --alarm-description "Database read latency is high" \
  --metric-name ReadLatency \
  --namespace AWS/RDS \
  --statistic Average \
  --period 300 \
  --threshold 0.1 \
  --comparison-operator GreaterThanThreshold \
  --evaluation-periods 2
```

#### Slow Query Monitoring

```sql
-- Enable slow query logging in PostgreSQL
ALTER SYSTEM SET log_min_duration_statement = 1000; -- Log queries > 1s
ALTER SYSTEM SET log_statement = 'all';
SELECT pg_reload_conf();

-- Query to identify slow queries
SELECT 
    query,
    mean_time,
    calls,
    total_time
FROM pg_stat_statements 
ORDER BY mean_time DESC 
LIMIT 10;
```

## 💰 Cost Monitoring

### Cost Optimization Monitoring

#### Cost Alerts

```bash
# Create cost budget
aws budgets create-budget \
  --account-id 123456789012 \
  --budget '{
    "BudgetName": "lecture-infrastructure-monthly",
    "BudgetLimit": {
      "Amount": "5000",
      "Unit": "USD"
    },
    "TimeUnit": "MONTHLY",
    "BudgetType": "COST"
  }' \
  --notifications-with-subscribers '[{
    "Notification": {
      "NotificationType": "ACTUAL",
      "ComparisonOperator": "GREATER_THAN",
      "Threshold": 80
    },
    "Subscribers": [{
      "SubscriptionType": "EMAIL",
      "Address": "finance@company.com"
    }]
  }]'
```

#### Resource Utilization Tracking

```python
# Lambda function for cost optimization recommendations
import boto3

def lambda_handler(event, context):
    ec2 = boto3.client('ec2')
    cloudwatch = boto3.client('cloudwatch')
    
    # Find underutilized instances
    instances = ec2.describe_instances()
    
    for reservation in instances['Reservations']:
        for instance in reservation['Instances']:
            instance_id = instance['InstanceId']
            
            # Get CPU utilization for last 7 days
            response = cloudwatch.get_metric_statistics(
                Namespace='AWS/EC2',
                MetricName='CPUUtilization',
                Dimensions=[{'Name': 'InstanceId', 'Value': instance_id}],
                StartTime=datetime.utcnow() - timedelta(days=7),
                EndTime=datetime.utcnow(),
                Period=3600,
                Statistics=['Average']
            )
            
            if response['Datapoints']:
                avg_cpu = sum(point['Average'] for point in response['Datapoints']) / len(response['Datapoints'])
                
                if avg_cpu < 5:  # Less than 5% CPU utilization
                    send_cost_optimization_alert(instance_id, avg_cpu)
```

## 🔧 Monitoring Automation

### Infrastructure as Code for Monitoring

```hcl
# Terraform module for monitoring setup
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "lecture-${var.customer}-overview"
  
  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ServiceName", "lecture-backend-service", "ClusterName", aws_ecs_cluster.main.name],
            ["AWS/RDS", "CPUUtilization", "DBClusterIdentifier", aws_rds_cluster.main.cluster_identifier]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "Infrastructure Health"
        }
      }
    ]
  })
}

# SNS topics for alerts
resource "aws_sns_topic" "alerts" {
  for_each = toset(["critical", "warning", "info"])
  name     = "lecture-${var.customer}-alerts-${each.key}"
}

# CloudWatch alarms
resource "aws_cloudwatch_metric_alarm" "ecs_cpu_high" {
  alarm_name          = "lecture-${var.customer}-ecs-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors ECS CPU utilization"
  alarm_actions       = [aws_sns_topic.alerts["warning"].arn]
  
  dimensions = {
    ServiceName = aws_ecs_service.main.name
    ClusterName = aws_ecs_cluster.main.name
  }
}
```

### Automated Monitoring Deployment

```bash
#!/bin/bash
# Script to deploy monitoring for all customers

CUSTOMERS=("dhbw" "edt" "unilux" "gva" "santillana" "educaria" "ufv" "edtufv")

for customer in "${CUSTOMERS[@]}"; do
  echo "Deploying monitoring for $customer..."
  
  export CUSTOMER=$customer
  export AWS_PROFILE="lecture-$customer-prod"
  
  # Deploy monitoring infrastructure
  terraform init -backend-config="lecture-$customer-prod-backend.hcl"
  terraform apply -var-file="lecture-$customer-prod-variables.tfvars" \
    -target=module.monitoring -auto-approve
  
  # Create custom dashboards
  aws cloudwatch put-dashboard \
    --dashboard-name "Lecture-$customer-Overview" \
    --dashboard-body "$(envsubst < dashboard-template.json)"
  
  # Set up log groups with retention
  aws logs create-log-group --log-group-name "/ecs/lecture-$customer-backend"
  aws logs put-retention-policy \
    --log-group-name "/ecs/lecture-$customer-backend" \
    --retention-in-days 30
  
  echo "Monitoring deployed for $customer ✅"
done
```

## 📞 Support and Escalation

### Monitoring Team Contacts

| Role | Contact | Responsibilities |
|------|---------|------------------|
| **Monitoring Lead** | monitoring-lead@company.com | Overall monitoring strategy |
| **SRE Engineer** | sre@company.com | Alerting and incident response |
| **DevOps Engineer** | devops@company.com | Infrastructure monitoring |
| **Security Analyst** | security@company.com | Security monitoring |

### On-Call Rotation

```bash
# PagerDuty integration for on-call management
curl -X POST \
  -H "Authorization: Token token=$PAGERDUTY_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "incident": {
      "type": "incident",
      "title": "Lecture Infrastructure Alert",
      "service": {
        "id": "$SERVICE_ID",
        "type": "service_reference"
      },
      "urgency": "high",
      "body": {
        "type": "incident_body",
        "details": "High CPU utilization detected on ECS cluster"
      }
    }
  }' \
  https://api.pagerduty.com/incidents
```

---

**Last Updated**: 2025-08-22  
**Version**: 2.0  
**Next Review**: 2025-11-22  
**Owner**: SRE Team