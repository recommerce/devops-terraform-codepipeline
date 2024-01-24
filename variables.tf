variable "env" {
  type    = string
  default = "dev"
}
variable "name" {
  type = string
}
variable "stages" {
  type = list(object({
    type     = string
    name     = string
    provider = string
    config   = map(string)
    inputs   = list(string)
    outputs  = list(string)
  }))
  default = []
}
variable "policy_statements" {
  type = list(
    object({
      actions   = list(string),
      resources = list(string),
      effect    = string
    })
  )
  default = []
}

variable "slack_notifications_enabled" {
  description = "Notification slack or not"
  type        = bool
}

variable "slack-notification-rule-codepipeline-name" {
  description = "Name of the codepipeline rule"
  type        = string
  default     = ""
}

variable "alerts_ci_slack_notifications_arn" {
  description = "sns slack address"
  type        = string
  default     = ""
}

variable "alerts_ci_slack_notifications_type" {
  description = "sns slack address"
  type        = string
  default     = "SNS"
}

variable "create_s3_artifact" {
  description = "create or not an S3 Artifact"
  type        = bool
  default     = true
}

variable "s3_artifact_Id" {
  description = "s3 artifact Id"
  type        = string
  default     = ""
}

variable "role_pipeline_name" {
  description = "pipeline role to use"
  type        = string
}