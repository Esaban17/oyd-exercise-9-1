output "log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.finapi.name
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic for alarm notifications"
  value       = aws_sns_topic.alerts.arn
}

output "alarm_http_5xx_name" {
  description = "Name of the HTTP 5xx error-rate CloudWatch alarm"
  value       = aws_cloudwatch_metric_alarm.http_5xx.alarm_name
}

output "alarm_latency_name" {
  description = "Name of the target response-time CloudWatch alarm"
  value       = aws_cloudwatch_metric_alarm.latency.alarm_name
}

output "alarm_estimated_charges_name" {
  description = "Name of the EstimatedCharges billing CloudWatch alarm"
  value       = aws_cloudwatch_metric_alarm.estimated_charges.alarm_name
}

output "budget_name" {
  description = "Name of the monthly AWS budget"
  value       = aws_budgets_budget.monthly.name
}
