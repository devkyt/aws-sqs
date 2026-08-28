# ---------------------------------------------
# Dead-Letter Queue For Failed Messages
# ---------------------------------------------
resource "aws_sqs_queue" "dead_letter" {
  name = "${local.name}-dlq${local.suffix}"

  delay_seconds              = 0
  message_retention_seconds  = var.dlq_message_retention_seconds
  visibility_timeout_seconds = var.visibility_timeout_seconds

  fifo_queue                  = var.fifo.enabled
  content_based_deduplication = var.fifo.enabled ? var.fifo.content_based_deduplication : null
  deduplication_scope         = var.fifo.enabled ? var.fifo.deduplication_scope : null
  fifo_throughput_limit       = var.fifo.enabled ? var.fifo.throughput_limit : null

  kms_master_key_id                 = var.encryption.kms_key_id
  kms_data_key_reuse_period_seconds = var.encryption.kms_key_id != null ? var.encryption.data_key_reuse_period_seconds : null

  tags = merge(local.tags,
    {
      Name = "${local.name}-dlq${local.suffix}"
      Type = "SQS Dead Letter Queue"
    }
  )
}
