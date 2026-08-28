# ---------------------------------------------
# Main Queue
# ---------------------------------------------
resource "aws_sqs_queue" "main" {
  name = "${local.name}-queue${local.suffix}"

  delay_seconds              = var.delay_seconds
  message_retention_seconds  = var.message_retention_seconds
  visibility_timeout_seconds = var.visibility_timeout_seconds

  fifo_queue                  = var.fifo.enabled
  content_based_deduplication = var.fifo.enabled ? var.fifo.content_based_deduplication : null
  deduplication_scope         = var.fifo.enabled ? var.fifo.deduplication_scope : null
  fifo_throughput_limit       = var.fifo.enabled ? var.fifo.throughput_limit : null

  kms_master_key_id                 = var.encryption.kms_key_id
  kms_data_key_reuse_period_seconds = var.encryption.kms_key_id != null ? var.encryption.data_key_reuse_period_seconds : null

  tags = merge(local.tags,
    {
      Name = "${local.name}-queue${local.suffix}"
      Type = "SQS Queue"
    }
  )
}


# ---------------------------------------------
# Redrive Policy Routing To The Dead-Letter Queue
# ---------------------------------------------
resource "aws_sqs_queue_redrive_policy" "main" {
  queue_url = aws_sqs_queue.main.id

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dead_letter.arn
    maxReceiveCount     = var.max_retry_count
  })
}
