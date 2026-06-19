terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
      # The us_east_1 alias is required for the EstimatedCharges alarm because
      # AWS/Billing metrics are only published in us-east-1.
      configuration_aliases = [aws.us_east_1]
    }
  }
}

# ---------------------------------------------------------------------------
# Task 1 — CloudWatch Log Group
# ---------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "finapi" {
  name              = "/finapi/dev"
  retention_in_days = var.log_retention_days

  tags = {
    Project     = "finapi"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}

# ---------------------------------------------------------------------------
# Task 1 — SNS Topic and Email Subscription
# ---------------------------------------------------------------------------
resource "aws_sns_topic" "alerts" {
  name = "finapi-alerts"

  tags = {
    Project     = "finapi"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.notification_email
}

# ---------------------------------------------------------------------------
# Task 2.1 — HTTP 5xx Error-Rate Alarm
# ---------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "http_5xx" {
  alarm_name          = "finapi-alb-http-5xx"
  alarm_description   = "Fires when ALB target 5xx responses >= 5 in two consecutive 60-second periods."
  namespace           = "AWS/ApplicationELB"
  metric_name         = "HTTPCode_Target_5XX_Count"
  statistic           = "Sum"
  period              = 60
  evaluation_periods  = 2
  threshold           = 5
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]

  tags = {
    Project     = "finapi"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}

# ---------------------------------------------------------------------------
# Task 2.2 — Target Response-Time (Latency) Alarm
# ---------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "latency" {
  alarm_name          = "finapi-alb-latency"
  alarm_description   = "Fires when average ALB target response time >= 1 second."
  namespace           = "AWS/ApplicationELB"
  metric_name         = "TargetResponseTime"
  statistic           = "Average"
  period              = 60
  evaluation_periods  = 2
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]

  tags = {
    Project     = "finapi"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}

# ---------------------------------------------------------------------------
# Task 3 — EstimatedCharges Billing Alarm (must use us-east-1 provider alias)
# ---------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "estimated_charges" {
  provider = aws.us_east_1

  alarm_name          = "finapi-estimated-charges"
  alarm_description   = "Fires when estimated AWS charges reach or exceed the configured threshold (USD)."
  namespace           = "AWS/Billing"
  metric_name         = "EstimatedCharges"
  statistic           = "Maximum"
  period              = 86400
  evaluation_periods  = 1
  threshold           = var.estimated_charges_threshold
  comparison_operator = "GreaterThanOrEqualToThreshold"

  dimensions = {
    Currency = "USD"
  }

  alarm_actions = [aws_sns_topic.alerts.arn]

  tags = {
    Project     = "finapi"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}

# ---------------------------------------------------------------------------
# Task 4 — Monthly Budget Guard
# ---------------------------------------------------------------------------
resource "aws_budgets_budget" "monthly" {
  name         = "finapi-monthly-budget"
  budget_type  = "COST"
  time_unit    = "MONTHLY"
  limit_amount = tostring(var.monthly_budget_usd)
  limit_unit   = "USD"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.notification_email]
  }
}
