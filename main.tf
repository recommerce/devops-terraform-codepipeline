data "aws_iam_role" "role" {
  name = var.role_pipeline_name
}

module "artifacts-policy" {
  count  = var.create_s3_artifact ? 1 : 0
  source            = "./modules/artifacts-policy"
  role_name         = data.aws_iam_role.role.name
  pipeline_bucket   = var.create_s3_artifact ? aws_s3_bucket.artifacts[*].arn!=null : data.aws_s3_bucket.datartifact.arn
  policy_statements = local.statements
}

resource "aws_s3_bucket" "artifacts" {
  count  = var.create_s3_artifact ? 1 : 0
  bucket = "${var.name}-${var.env}"
}

data "aws_s3_bucket" "datartifact" {
  bucket = var.s3_artifact_Id
}

resource "aws_codepipeline" "pipeline" {
  name     = "${var.name}-${var.env}"
  role_arn = data.aws_iam_role.role.arn

  artifact_store {
    location = var.create_s3_artifact ? aws_s3_bucket.artifacts[*].id!=null : data.aws_s3_bucket.datartifact.id
    type     = "S3"
  }

  dynamic "stage" {
    for_each = var.stages
    content {
      name = stage.value.name
      action {
        name             = stage.value.name
        category         = stage.value.type
        configuration    = stage.value.config
        owner            = "AWS"
        provider         = stage.value.provider
        run_order        = stage.key + 1
        version          = "1"
        input_artifacts  = stage.value.inputs
        output_artifacts = stage.value.outputs
      }
    }
  }
}

resource "aws_codestarnotifications_notification_rule" "aws_codestarnotifications_notification_rule_codepipeline" {
  count = var.slack_notifications_enabled ? 1 : 0
  detail_type = "BASIC"
  event_type_ids = [
    "codepipeline-pipeline-pipeline-execution-failed",
    "codepipeline-pipeline-pipeline-execution-started",
    "codepipeline-pipeline-pipeline-execution-succeeded"
  ]

  name     = var.slack-notification-rule-codepipeline-name
  resource = aws_codepipeline.pipeline.arn

  target {
    address = var.alerts_ci_slack_notifications_arn
  }
}
