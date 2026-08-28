# ---------------------------------------------
# Queue Access Policy From Provided Statements
# ---------------------------------------------
data "aws_iam_policy_document" "queue_policy" {
  dynamic "statement" {
    for_each = var.queue_policy_statements
    content {
      sid       = statement.value.sid
      effect    = statement.value.effect
      actions   = statement.value.actions
      resources = [aws_sqs_queue.main.arn]

      principals {
        type        = statement.value.principals.type
        identifiers = statement.value.principals.identifiers
      }

      dynamic "condition" {
        for_each = statement.value.conditions
        content {
          test     = condition.value.test
          variable = condition.value.variable
          values   = condition.value.values
        }
      }
    }
  }

  lifecycle {
    enabled = length(var.queue_policy_statements) > 0
  }
}


resource "aws_sqs_queue_policy" "main" {
  queue_url = aws_sqs_queue.main.id
  policy    = data.aws_iam_policy_document.queue_policy.json

  lifecycle {
    enabled = length(var.queue_policy_statements) > 0
  }
}
