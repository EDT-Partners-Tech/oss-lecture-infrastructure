# © [2025] EDT&Partners. Licensed under CC BY 4.0.
#
# ECS Task Definition
#
#
# IAM roles, policies: ECS Service
#
resource "aws_iam_role" "ecs_service_role" {
  name = "${var.module}-ecs-service-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = [
            "ecs.amazonaws.com",
            "ecs-tasks.amazonaws.com"
          ]
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "ecs_service_policy" {
  name        = "${var.module}-ecs-service-policy"
  description = "IAM policy for ECS service role used by ${var.module}"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:*",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:Get*",
          "ecs:Describe*",
          "ecs:List*",
          "ecs:RegisterContainerInstance",
          "ecs:UpdateContainerAgent",
          "ecs:StartTask",
          "ecs:StopTask",
          "ecs:RunTask",
          "cloudwatch:DescribeAlarms",
          "cloudwatch:DeleteAlarms",
          "cloudwatch:PutMetricAlarm",
          "elasticfilesystem:ClientMount",
          "logs:*",
          "lambda:InvokeFunction",
          "ssm:Describe*",
          "ssm:Get*",
          "ssm:List*",
          "secretsmanager:Get*",
          "secretsmanager:Describe*",
          "secretsmanager:List*",
          "sts:AssumeRole",
          "sts:GetCallerIdentity",
          "bedrock:*",
          "states:*",
          "translate:*",
          "comprehend:*",
          "polly:*",
          "textract:*",
          "aoss:*",
          "transcribe:*",
          "cognito-idp:*"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_service_role_attach" {
  role       = aws_iam_role.ecs_service_role.name
  policy_arn = aws_iam_policy.ecs_service_policy.arn
}

resource "aws_ecs_task_definition" "td" {
  family                   = "${var.module}-task"
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  task_role_arn            = aws_iam_role.ecs_service_role.arn
  execution_role_arn       = aws_iam_role.ecs_service_role.arn

  container_definitions = jsonencode([
    {
      name                   = "${var.module}",
      image                  = "${aws_ecr_repository.lecture_ecr.repository_url}:latest",
      essential              = true,
      readonlyRootFilesystem = false,

      portMappings = [
        {
          protocol      = "tcp",
          containerPort = "${var.port}"
        }
      ],

      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = "${aws_cloudwatch_log_group.ecs_cf_log_group.name}",
          awslogs-region        = "${var.region}",
          awslogs-stream-prefix = "/ecs"
        }
      },

      secrets = [
        {
          "name" : "API_PASSWORD",
          "valueFrom" : "/lecture/global/STA_API_PASSWORD"
        },
        {
          "name" : "AWS_ATHENA_DATABASE",
          "valueFrom" : "/lecture/global/AWS_ATHENA_DATABASE"
        },
        {
          "name" : "AWS_ATHENA_MAIN_TABLE",
          "valueFrom" : "/lecture/global/AWS_ATHENA_MAIN_TABLE"
        },
        {
          "name" : "AWS_ATHENA_OUTPUT_FOLDER_NAME",
          "valueFrom" : "/lecture/global/AWS_ATHENA_OUTPUT_FOLDER_NAME"
        },
        {
          "name" : "AWS_ATHENA_OUTPUT_S3",
          "valueFrom" : "/lecture/global/AWS_ATHENA_OUTPUT_S3"
        },
        {
          "name" : "AWS_ATHENA_TOPICS_TABLE",
          "valueFrom" : "/lecture/global/AWS_ATHENA_TOPICS_TABLE"
        },
        {
          "name" : "AWS_S3_BUCKET_NAME",
          "valueFrom" : "/lecture/global/AWS_S3_BUCKET_NAME"
        },
        {
          "name" : "AWS_POLLY_SPEECH_ENGINE",
          "valueFrom" : "/lecture/global/AWS_POLLY_SPEECH_ENGINE"
        },
        {
          "name" : "AWS_REGION_NAME",
          "valueFrom" : "/lecture/global/AWS_REGION_NAME"
        },
        {
          "name" : "AWS_S3_AUDIO_BUCKET_NAME",
          "valueFrom" : "/lecture/global/AWS_S3_AUDIO_BUCKET_NAME"
        },
        {
          "name" : "AWS_S3_COMPARISON_BUCKET_NAME",
          "valueFrom" : "/lecture/global/AWS_S3_COMPARISON_BUCKET_NAME"
        },
        {
          "name" : "AWS_S3_CONTENT_BUCKET_NAME",
          "valueFrom" : "/lecture/global/AWS_S3_CONTENT_BUCKET_NAME"
        },
        {
          "name" : "AWS_S3_PODCAST_BUCKET_NAME",
          "valueFrom" : "/lecture/global/AWS_S3_PODCAST_BUCKET_NAME"
        },
        {
          "name" : "COGNITO_APP_CLIENT_ID",
          "valueFrom" : "/lecture/global/COGNITO_APP_CLIENT_ID"
        },
        {
          "name" : "COGNITO_REGION",
          "valueFrom" : "/lecture/global/COGNITO_REGION"
        },
        {
          "name" : "COGNITO_USERPOOL_ID",
          "valueFrom" : "/lecture/global/COGNITO_USERPOOL_ID"
        },
        {
          "name" : "DATABASE_SECRET",
          "valueFrom" : "/lecture/global/DATABASE_SECRET"
        },
        {
          "name" : "SECRET_KEY",
          "valueFrom" : "/lecture/global/STA_SECRET_KEY"
        },
        {
          "name" : "AWS_AGENT_ID",
          "valueFrom" : "/lecture/global/AWS_AGENT_ID"
        },
        {
          "name" : "AWS_AGENT_ALIAS_ID",
          "valueFrom" : "/lecture/global/AWS_AGENT_ALIAS_ID"
        },
        {
          "name" : "AWS_KNOWLEDGE_BASE_ID",
          "valueFrom" : "/lecture/global/AWS_KNOWLEDGE_BASE_ID"
        }
      ]
    }
  ])
}

