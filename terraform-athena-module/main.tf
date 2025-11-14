# © [2025] EDT&Partners. Licensed under CC BY 4.0.
resource "aws_s3_bucket" "this" {
  bucket = "${var.project}-${var.region}-std-data"
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}


resource "aws_glue_catalog_database" "this" {
  name = "${var.project}-std"
}


locals {
  feedback_comments_columns = [
    { name = "student_id", type = "int" },
    { name = "reached_end", type = "boolean" },
    { name = "completion_time", type = "int" },
    { name = "location", type = "string" },
    { name = "situation", type = "string" },
    { name = "faculty", type = "string" },
    { name = "degree", type = "string" },
    { name = "course", type = "string" },
    { name = "class_shift", type = "string" },
    { name = "commute_time", type = "string" },
    { name = "gender", type = "string" },
    { name = "scholarship", type = "boolean" },
    { name = "ufv_position", type = "string" },
    { name = "degree_certainty", type = "boolean" },
    { name = "expectations_quant", type = "int" },
    { name = "expectations_qual", type = "string" },
    { name = "pastoral_activities", type = "boolean" },
    { name = "pastoral_participation", type = "boolean" },
    { name = "mission_identification", type = "string" },
    { name = "not_listened", type = "string" },
    { name = "suggestion", type = "string" },
    { name = "degree_recommendation_quant", type = "int" },
    { name = "degree_recommendation_qual", type = "string" },
    { name = "satisfaction", type = "int" },
    { name = "re_enroll", type = "string" },
    { name = "recommendation", type = "int" },
    { name = "expectations_qual_topic", type = "string" },
    { name = "degree_recommendation_qual_topic", type = "string" },
    { name = "not_listened_topic", type = "string" },
    { name = "suggestion_topic", type = "string" }
  ]
}


resource "aws_glue_catalog_table" "feedback_comments" {
  name          = "feedback_comments"
  database_name = "${var.project}-std"

  table_type = "EXTERNAL_TABLE"

  parameters = {
    EXTERNAL           = "TRUE"
    classification     = "parquet"
    has_encrypted_data = "false"
  }

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.this.bucket}/quantitative_data/"
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"

    ser_de_info {
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"
      parameters = {
        "serialization.format" = "1"
      }
    }

    dynamic "columns" {
      for_each = local.feedback_comments_columns
      content {
        name = columns.value.name
        type = columns.value.type
      }
    }

    stored_as_sub_directories = false
  }

}

locals {
  topics_stats_columns = [
    { name = "question_name", type = "string" },
    { name = "topic", type = "string" },
    { name = "float", type = "string" },
    { name = "satisfaction_average", type = "float" },
    { name = "quant_group", type = "int" }

  ]
}
resource "aws_glue_catalog_table" "topics_stats" {
  name          = "topics_stats"
  database_name = "${var.project}-std"

  table_type = "EXTERNAL_TABLE"

  parameters = {
    EXTERNAL           = "TRUE"
    classification     = "parquet"
    has_encrypted_data = "false"
  }

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.this.bucket}/topics_data/"
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"

    ser_de_info {
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"
      parameters = {
        "serialization.format" = "1"
      }
    }

    dynamic "columns" {
      for_each = local.topics_stats_columns
      content {
        name = columns.value.name
        type = columns.value.type
      }
    }

    stored_as_sub_directories = false
  }
}


locals {
  modules_env = {
    AWS_S3_BUCKET_NAME            = aws_s3_bucket.this.bucket
    AWS_ATHENA_DATABASE           = aws_glue_catalog_database.this.name
    AWS_ATHENA_MAIN_TABLE         = aws_glue_catalog_table.feedback_comments.name
    AWS_ATHENA_TOPICS_TABLE       = aws_glue_catalog_table.topics_stats.name
    AWS_ATHENA_OUTPUT_FOLDER_NAME = "athena"
    AWS_ATHENA_OUTPUT_S3          = aws_s3_bucket.this.bucket
  }
  module_variables = flatten([
    for name, value in local.modules_env : {
      name        = "/lecture/global/${name}"
      value       = "${value}"
      type        = "String"
      overwrite   = "true"
      description = ""
    }
  ])
}

module "ssm_dynamic_variables" {
  source               = "cloudposse/ssm-parameter-store/aws"
  ignore_value_changes = "true"
  parameter_write      = local.module_variables
}
