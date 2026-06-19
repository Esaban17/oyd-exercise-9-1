output "log_group_name" {
  description = "CloudWatch log group name for FinAPI"
  value       = module.observability.log_group_name
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic used for alarm notifications"
  value       = module.observability.sns_topic_arn
}

output "alarm_http_5xx_name" {
  description = "Name of the HTTP 5xx error-rate alarm"
  value       = module.observability.alarm_http_5xx_name
}

output "alarm_latency_name" {
  description = "Name of the target response-time alarm"
  value       = module.observability.alarm_latency_name
}

output "alarm_estimated_charges_name" {
  description = "Name of the EstimatedCharges billing alarm"
  value       = module.observability.alarm_estimated_charges_name
}

output "budget_name" {
  description = "Name of the monthly cost budget"
  value       = module.observability.budget_name
}
