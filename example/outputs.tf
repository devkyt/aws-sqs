output "queue_url" {
  description = "URL of the created queue"
  value       = module.sqs.queue_url
}


output "queue_arn" {
  description = "ARN of the created queue"
  value       = module.sqs.queue_arn
}


output "dead_letter_url" {
  description = "URL of the created dead letter queue"
  value       = module.sqs.dead_letter_url
}
