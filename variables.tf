variable "queue_name" {
  description = "Name of the SQS queue"
  type        = string
  default     = null

  validation {
    condition     = var.queue_name == null || length(var.queue_name) > 0
    error_message = "Queue name cannot be empty."
  }

  validation {
    condition     = var.queue_name == null || can(regex("^[a-zA-Z0-9-_]+$", var.queue_name))
    error_message = "Queue name must contain only letters, numbers, hyphens, and underscores."
  }
}


variable "app" {
  description = "Application name"
  type        = string

  validation {
    condition     = length(var.app) > 0
    error_message = "Application name cannot be empty."
  }

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.app))
    error_message = "Application name must contain only lowercase letters, numbers, and hyphens."
  }
}


variable "env" {
  description = "Target environment"
  type        = string

  validation {
    condition     = length(var.env) > 0
    error_message = "Environment cannot be empty."
  }

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.env))
    error_message = "Environment must contain only lowercase letters, numbers, and hyphens."
  }
}


variable "delay_seconds" {
  description = "Delay in seconds before message becomes available"
  type        = number
  default     = 0

  validation {
    condition     = var.delay_seconds >= 0 && var.delay_seconds <= 900
    error_message = "Delay must be between 0 and 900 seconds."
  }
}


variable "message_retention_seconds" {
  description = "Message retention period in seconds"
  type        = number
  default     = 345600

  validation {
    condition     = var.message_retention_seconds >= 60 && var.message_retention_seconds <= 1209600
    error_message = "Retention must be between 60 seconds and 14 days (1209600 seconds)."
  }
}


variable "max_retry_count" {
  description = "Maximum retries before moving message to dead letter queue"
  type        = number
  default     = 5

  validation {
    condition     = var.max_retry_count > 0
    error_message = "Max receive count must be positive."
  }
}


variable "visibility_timeout_seconds" {
  description = "Visibility timeout in seconds"
  type        = number
  default     = 30

  validation {
    condition     = var.visibility_timeout_seconds >= 0 && var.visibility_timeout_seconds <= 43200
    error_message = "Visibility timeout must be between 0 and 43200 seconds (12 hours)."
  }
}


variable "fifo" {
  description = "FIFO queue configuration"
  type = object({
    enabled                     = bool
    content_based_deduplication = optional(bool, false)
    deduplication_scope         = optional(string, "queue")
    throughput_limit            = optional(string, "perQueue")
  })
  default = {
    enabled = false
  }

  validation {
    condition     = !var.fifo.enabled ? true : contains(["messageGroup", "queue"], var.fifo.deduplication_scope)
    error_message = "Deduplication scope must be 'messageGroup' or 'queue'."
  }

  validation {
    condition     = !var.fifo.enabled ? true : contains(["perQueue", "perMessageGroupId"], var.fifo.throughput_limit)
    error_message = "FIFO throughput limit must be 'perQueue' or 'perMessageGroupId'."
  }
}


variable "encryption" {
  description = "Encryption configuration. Encryption is enabled when kms_key_id is provided."
  type = object({
    kms_key_id                    = optional(string, null)
    data_key_reuse_period_seconds = optional(number, 300)
  })
  default = {}

  validation {
    condition     = var.encryption.kms_key_id == null || can(regex("^arn:aws:kms:[a-z0-9-]+:[0-9]{12}:key/[a-f0-9-]+$", var.encryption.kms_key_id))
    error_message = "KMS key ID must be a valid KMS key ARN."
  }

  validation {
    condition     = var.encryption.data_key_reuse_period_seconds >= 60 && var.encryption.data_key_reuse_period_seconds <= 86400
    error_message = "KMS data key reuse period must be between 60 and 86400 seconds."
  }
}


variable "dlq_message_retention_seconds" {
  description = "Dead letter queue message retention period in seconds"
  type        = number
  default     = 1209600

  validation {
    condition     = var.dlq_message_retention_seconds >= 60 && var.dlq_message_retention_seconds <= 1209600
    error_message = "DLQ retention must be between 60 seconds and 14 days (1209600 seconds)."
  }
}


variable "queue_policy_statements" {
  description = "IAM policy statements for the queue policy. Resource is automatically set to the queue ARN."
  type = list(object({
    sid    = optional(string)
    effect = optional(string, "Allow")
    principals = object({
      type        = string
      identifiers = list(string)
    })
    actions = list(string)
    conditions = optional(list(object({
      test     = string
      variable = string
      values   = list(string)
    })), [])
  }))
  default = []
}


variable "use_name_prefix" {
  description = "Use name_prefix instead of a fixed name for the resources this module creates, so AWS appends a unique suffix"
  type        = bool
  default     = false
}


variable "include_default_tags" {
  description = "Whether or not to attach default tags specified in module"
  type        = bool
  default     = true
}


variable "tags" {
  description = "Tags to apply to SQS and the related resources"
  type        = map(string)
  default     = {}
}
