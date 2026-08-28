output "queue_url" {
  description = "URL of the created queue"
  value       = aws_sqs_queue.main.id
}


output "queue_arn" {
  description = "ARN of the created queue"
  value       = aws_sqs_queue.main.arn
}


output "queue_name" {
  description = "Name of the created queue"
  value       = aws_sqs_queue.main.name
}


output "dead_letter_url" {
  description = "URL of the created dead letter queue"
  value       = aws_sqs_queue.dead_letter.id
}


output "dead_letter_arn" {
  description = "ARN of the created dead letter queue"
  value       = aws_sqs_queue.dead_letter.arn
}


output "dead_letter_name" {
  description = "Name of the created dead letter queue"
  value       = aws_sqs_queue.dead_letter.name
}
