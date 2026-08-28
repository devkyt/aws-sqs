# AWS SQS

OpenTofu module for SQS queue provisioning with a dead letter queue. You can find how to use it
in [example](./example/) folder and in the [Examples](#examples) section below.

## Table of Contents

- [Requirements](#requirements)
- [Inputs](#inputs)
- [Outputs](#outputs)
- [Examples](#examples)
  - [Basic Queue](#basic-queue)
  - [FIFO Queue](#fifo-queue)
  - [Queue with IAM Policy](#queue-with-iam-policy)
  - [KMS Encryption](#kms-encryption)
  - [Custom Retention and Visibility](#custom-retention-and-visibility)

## Requirements

| Name | Version |
|------|---------|
| OpenTofu | >= 1.11 |
| AWS provider | ~> 6.0  |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `queue_name` | Name of the SQS queue | `string` | `null` | no |
| `app` | Application name | `string` | - | yes |
| `env` | Target environment | `string` | - | yes |
| `delay_seconds` | Delay in seconds before message becomes available | `number` | `0` | no |
| `message_retention_seconds` | Message retention period in seconds | `number` | `345600` | no |
| `max_retry_count` | Maximum retries before moving message to dead letter queue | `number` | `5` | no |
| `visibility_timeout_seconds` | Visibility timeout in seconds | `number` | `30` | no |
| `fifo` | FIFO queue configuration | `object` | `{ enabled = false }` | no |
| `encryption` | Encryption configuration. Encryption is enabled when kms_key_id is provided | `object` | `{}` | no |
| `dlq_message_retention_seconds` | Dead letter queue message retention period in seconds | `number` | `1209600` | no |
| `queue_policy_statements` | IAM policy statements for the queue policy. Resource is automatically set to the queue ARN | `list(object)` | `[]` | no |
| `use_name_prefix` | Use name_prefix instead of a fixed name for created resources, so AWS appends a unique suffix | `bool` | `false` | no |
| `include_default_tags` | Whether or not to attach default tags specified in module | `bool` | `true` | no |
| `tags` | Tags to apply to SQS and the related resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `queue_url` | URL of the created queue |
| `queue_arn` | ARN of the created queue |
| `queue_name` | Name of the created queue |
| `dead_letter_url` | URL of the created dead letter queue |
| `dead_letter_arn` | ARN of the created dead letter queue |
| `dead_letter_name` | Name of the created dead letter queue |

## Examples

### Basic Queue

A minimal SQS queue with a dead letter queue created automatically.

```hcl
module "sqs" {
  source = "git@github.com:devkyt/aws-sqs.git?ref=main&depth=1"

  app = "notifications"
  env = "experiment"
}
```

### FIFO Queue

A FIFO queue with content-based deduplication and high throughput mode.

```hcl
module "sqs" {
  source = "git@github.com:devkyt/aws-sqs.git?ref=main&depth=1"

  app = "notifications"
  env = "experiment"

  fifo = {
    enabled                     = true
    content_based_deduplication = true
    deduplication_scope         = "messageGroup"
    throughput_limit            = "perMessageGroupId"
  }
}
```

### Queue with IAM Policy

Allowing an SNS topic to send messages to the queue.

```hcl
module "sqs" {
  source = "git@github.com:devkyt/aws-sqs.git?ref=main&depth=1"

  app = "notifications"
  env = "experiment"

  queue_policy_statements = [
    {
      sid = "AllowSNSPublish"
      principals = {
        type        = "Service"
        identifiers = ["sns.amazonaws.com"]
      }
      actions = ["sqs:SendMessage"]
      conditions = [
        {
          test     = "ArnEquals"
          variable = "aws:SourceArn"
          values   = ["arn:aws:sns:eu-central-1:123456789012:alerts"]
        }
      ]
    }
  ]
}
```

### KMS Encryption

Using a custom KMS key for server-side encryption.

```hcl
module "sqs" {
  source = "git@github.com:devkyt/aws-sqs.git?ref=main&depth=1"

  app = "notifications"
  env = "experiment"

  encryption = {
    kms_key_id                    = "arn:aws:kms:eu-central-1:123456789012:key/a1b2c3d4-e5f6-7890-abcd-ef1234567890"
    data_key_reuse_period_seconds = 600
  }
}
```

### Custom Retention and Visibility

Adjusting message retention, visibility timeout, and retry count.

```hcl
module "sqs" {
  source = "git@github.com:devkyt/aws-sqs.git?ref=main&depth=1"

  app = "notifications"
  env = "experiment"

  message_retention_seconds  = 1209600
  visibility_timeout_seconds = 120
  max_retry_count            = 10
  delay_seconds              = 5

  dlq_message_retention_seconds = 1209600
}
```

## License

Licensed under the Apache License, Version 2.0.

Copyright 2026 Kyrylo Tykhanskyi.
