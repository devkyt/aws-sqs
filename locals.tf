locals {
  name = coalesce(var.queue_name, "${var.app}-${var.env}")

  suffix = var.fifo.enabled ? ".fifo" : ""

  default_tags = var.include_default_tags ? {
    App         = var.app
    Environment = var.env
    Env         = var.env
    Terraform   = "true"
    ManagedBy   = "Terraform"
  } : {}

  tags = merge(local.default_tags, var.tags)
}
