resource "aws_iam_role" "role" {
  name               = "${var.name}-codepipeline-${var.env}"
  assume_role_policy = data.aws_iam_policy_document.assume-role.json
}

module "artifacts-policy" {
  source            = "./modules/artifacts-policy"
  role_name         = aws_iam_role.role.name
  pipeline_bucket   = aws_s3_bucket.artifacts.arn
  policy_statements = local.statements
}

resource "aws_s3_bucket" "artifacts" {
  bucket = "${var.name}-artifacts-${var.env}"
}

resource "aws_codepipeline" "pipeline" {
  name     = "${var.name}-${var.env}"
  role_arn = aws_iam_role.role.arn

  artifact_store {
    location = aws_s3_bucket.artifacts.id
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
