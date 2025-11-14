# © [2025] EDT&Partners. Licensed under CC BY 4.0.
locals {
  s3_config = [
    {
      s3_name         = "content-${var.project}-${var.environment}"
      s3_block_public = true
      ssm_key         = "AWS_S3_CONTENT_BUCKET_NAME"

    },
    {
      s3_name         = "audiofiles-${var.project}-${var.environment}"
      s3_block_public = true
      ssm_key         = "AWS_S3_AUDIO_BUCKET_NAME"

    },
    {
      s3_name         = "podcasts-${var.project}-${var.environment}"
      s3_block_public = true
      ssm_key         = "AWS_S3_PODCAST_BUCKET_NAME"
    },
    {
      s3_name         = "comparison-${var.project}-${var.environment}"
      s3_block_public = true
      ssm_key         = "AWS_S3_COMPARISON_BUCKET_NAME"
    },
    {
      s3_name         = "contentgenerator-${var.project}-${var.environment}"
      s3_block_public = true
      ssm_key         = "AWS_S3_CONTENTGENERATOR_BUCKET_NAME"
    }
  ]
}


locals {
  lambda_layers = [
    {
      filename = "combined_layers_311"
    },
    {
      filename    = "sta_layer_texttosql"
      lambda_name = "lecture-sta-backend"
    }
  ]
}

locals {
  ec2_config = [
    {
      name = "lecture-be"
    }
  ]
}
locals {
  ecs_config = [
    {
      name             = "lecture-backend"
      repository_name  = "lecture-backend"
      task_cpu         = "2048"
      task_memory      = "4096"
      asg_min_capacity = 1
      asg_max_capacity = 3
    },
    {
      name             = "lecture-sta-backend"
      repository_name  = "lecture-sta-backend"
      task_cpu         = "512"
      task_memory      = "1024"
      asg_min_capacity = 1
      asg_max_capacity = 3

    }
  ]
}
locals {
  cloudfront_configs = [
    {
      repository         = "lecture-frontend-${var.route53_domain}-${var.aws_region}"
      domain_alias       = ["frontend", "${var.project}"]
      enable_bucket_cors = false
      repository_name    = "lecture-frontend"
      enable_root_domain = var.enable_root_domain
    },
    {
      repository         = "lecture-sta-frontend-${var.route53_domain}-${var.aws_region}"
      domain_alias       = ["sta"]
      enable_bucket_cors = false
      repository_name    = "lecture-sta-frontend"
    },
        {
      repository         = "lecture-contentgenerator-${var.route53_domain}-${var.aws_region}"
      domain_alias       = ["contentgenerator"]
      enable_bucket_cors = false
      repository_name    = "lecture-contentgenerator"
    }
  ]
}

locals {
  dynamodb_configs = [
    {
      table_name = "async-transcription-jobs"
    }
  ]
}


locals {
  lambda_env = {
    AWS_REGION_NAME            = var.aws_region
    AWS_S3_CONTENT_BUCKET_NAME = "content-${var.project}-${var.environment}"
  }
}


locals {
  lambda_configs = [
    {
      repository         = "createOpensearchCollection"
      lambda_handler     = "lambda_function.lambda_handler"
      lambda_timeout     = "60"
      lambda_memory_size = "128"
      lambda_runtime     = "python3.13"

    },
    {
      repository         = "PreSignupRestrictDomainLambda"
      lambda_handler     = "lambda_function.lambda_handler"
      lambda_timeout     = "60"
      lambda_memory_size = "128"
      lambda_runtime     = "python3.12"

    },
    {
      repository         = "startTranscriptionJob"
      lambda_handler     = "lambda_function.lambda_handler"
      lambda_timeout     = "60"
      lambda_memory_size = "128"
      lambda_runtime     = "python3.13"

    },
    {
      repository         = "transcribeCallbackLambda"
      lambda_handler     = "lambda_function.lambda_handler"
      lambda_timeout     = "60"
      lambda_memory_size = "128"
      lambda_runtime     = "python3.13"

    },
    {
      repository         = "createOpensearchVectorIndex"
      lambda_handler     = "lambda_function.lambda_handler"
      lambda_timeout     = "60"
      lambda_memory_size = "128"
      lambda_runtime     = "python3.13"

    },
    {
      repository         = "createBedrockKnowledgeBase"
      lambda_handler     = "lambda_function.lambda_handler"
      lambda_timeout     = "60"
      lambda_memory_size = "128"
      lambda_runtime     = "python3.13"

    },
    {
      repository         = "createKnowledgeBaseDataSource"
      lambda_handler     = "lambda_function.lambda_handler"
      lambda_timeout     = "60"
      lambda_memory_size = "128"
      lambda_runtime     = "python3.13"
    },
    {
      repository         = "agentApiHangler"
      lambda_handler     = "lambda_function.lambda_handler"
      lambda_timeout     = "60"
      lambda_memory_size = "128"
      lambda_runtime     = "python3.13"
    },
    {
      repository         = "textToSql"
      lambda_handler     = "lambda_function.lambda_handler"
      lambda_timeout     = "180"
      lambda_memory_size = "128"
      lambda_runtime     = "python3.12"
    },

  ]
}


locals {
  state_machines = [
    {
      name        = "CreateKnowledgeBaseInfrastructure"
      description = "A state machine for creating OpenSearch collection, index, Bedrock knowledge base, and data source."
      lambda_arns = {
        create_collection  = "arn:aws:lambda:${var.aws_region}:${data.aws_caller_identity.current.account_id}:function:createOpensearchCollection"
        create_index       = "arn:aws:lambda:${var.aws_region}:${data.aws_caller_identity.current.account_id}:function:createOpensearchVectorIndex"
        create_kb          = "arn:aws:lambda:${var.aws_region}:${data.aws_caller_identity.current.account_id}:function:createBedrockKnowledgeBase"
        create_data_source = "arn:aws:lambda:${var.aws_region}:${data.aws_caller_identity.current.account_id}:function:createKnowledgeBaseDataSource"
      }
    },
    {
      name        = "TestPreprocessingTranscriptions"
      description = "A state machine for creating OpenSearch collection, index, Bedrock knowledge base, and data source."
      lambda_arns = {
        create_collection  = "arn:aws:lambda:${var.aws_region}:${data.aws_caller_identity.current.account_id}:function:startTranscriptionJob"
        create_index       = "arn:aws:lambda:${var.aws_region}:${data.aws_caller_identity.current.account_id}:function:createOpensearchVectorIndex"
        create_kb          = "arn:aws:lambda:${var.aws_region}:${data.aws_caller_identity.current.account_id}:function:createBedrockKnowledgeBase"
        create_data_source = "arn:aws:lambda:${var.aws_region}:${data.aws_caller_identity.current.account_id}:function:createKnowledgeBaseDataSource"
      }
    },
  ]
}


locals {
  modules_env = {
    AWS_REGION_NAME         = "${var.aws_region}",
    COGNITO_REGION          = "${var.aws_region}",
    STA_SECRET_KEY          = "r4e3w2q1",
    STA_API_PASSWORD        = "q1w2e3r4",
    COGNITO_REGION          = "${var.aws_region}",
    AWS_POLLY_SPEECH_ENGINE = "generative",
    AWS_KNOWLEDGE_BASE_ID   = "null",
    AWS_AGENT_ALIAS_ID      = "null",
    AWS_AGENT_ID            = "null",
	BACKEND_DOMAIN_NAME		= "lecture-backend.${var.route53_domain}"
  }
  json_dynamic_variables = flatten([
    for name, value in local.modules_env : {
      name        = "/lecture/global/${name}"
      value       = "${value}"
      type        = "String"
      overwrite   = "true"
      description = ""
    }
  ])
}
locals {
  secrets_env = {
    LTI_ENCRYPTION_SECRET = { type = "base64", rotation = false }
    LTI_SESSION_SECRET    = { type = "base64", rotation = false }
    SESSION_SECRET        = { type = "hex", rotation = true }
  }

  secrets_dynamic_variables = {
    for name, config in local.secrets_env : name => {
      name         = "/lecture/global/${name}/${var.secrets_uuid}"
      type         = config.type
      custom_value = lookup(config, "value", null)
    }
  }
}


############################## BEDROCK##########################################

locals {
  claude_models = [
    for m in data.aws_bedrock_foundation_models.all.model_summaries : m.model_id
    if can(regex("claude", lower(m.model_id)))
  ]

  sorted_claude_models_desc = reverse(sort(local.claude_models))
  latest_claude_model       = local.sorted_claude_models_desc[0]
}


locals {
  agents = {
    agent-without-knowledgebases = {
      agent_name       = "agent-without-knowledgebases"
      foundation_model = local.latest_claude_model
      action_groups = {

      }
    }
    agent-with-knowledgebases = {
      agent_name       = "agent-with-knowledgebases"
      foundation_model = local.latest_claude_model
      action_groups = {
        ag1 = {
          custom_control = "RETURN_CONTROL"
          files = [
            "func1.json"
          ]
        }

      }
    }
    agent-external = {
      agent_name       = "agent-external"
      foundation_model = local.latest_claude_model
      action_groups = {
        ag1 = {
          custom_control = "RETURN_CONTROL"
          files = [
            "func1.json",
            "func2.json"
          ]

        }
        ag2 = {
          lambda_executor_arn = "arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:agentApiHangler"
          files = [
            "func1.json"
          ]
        }
      }
    }
  }
}
