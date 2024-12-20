terraform {
  required_providers {
    template = {
      source = "hashicorp/template"
      version = "2.2.0"
    }
  }
}

provider "template" {
  # Configuration options
}
provider "aws" {
  region = var.aws_region
}

# Create the SNS Topic
resource "aws_sns_topic" "billing_alert" {
  name = var.sns_topic_name
  tags = {
    Environment = var.environment_tag
    Purpose     = "BillingAlerts"
  }
}

# Loop through the thresholds to create multiple alarms
resource "aws_cloudwatch_metric_alarm" "estimated_charges" {
  count               = length(var.alert_thresholds)
  alarm_name          = "estimated-charges-${var.alert_thresholds[count.index]}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "EstimatedCharges"
  namespace           = "AWS/Billing"
  period              = "86400" # 24 hours in seconds
  statistic           = "Maximum"
  threshold           = var.alert_thresholds[count.index]
  alarm_description   = "Alarm when AWS charges go above ${var.alert_thresholds[count.index]} ${var.currency}"
  alarm_actions       = [aws_sns_topic.billing_alert.arn]
  treat_missing_data  = "notBreaching"
  dimensions = {
    Currency = var.currency
  }
  tags = {
    Environment = var.environment_tag
    Purpose     = "BillingAlerts"
  }
}

# Add email subscription to SNS topic
# resource "aws_sns_topic_subscription" "email_alert" {
#   topic_arn = aws_sns_topic.billing_alert.arn
#   protocol  = "email"
#   endpoint  = var.email_endpoint

#   # Automatically confirm subscription if enabled
#   depends_on = [aws_sns_topic.billing_alert]
#   provisioner "local-exec" {
#     when    = "create"
#     command = "echo 'Auto-confirm subscription is enabled.'"
#     interpreter = ["/bin/bash"]
#   }
# }
resource "aws_sns_topic_subscription" "email_alert" {
  topic_arn = aws_sns_topic.billing_alert.arn
  protocol  = "email"
  endpoint  = var.email_endpoint

  depends_on = [aws_sns_topic.billing_alert]
}

# Note: Auto-confirmation of the email subscription must be done manually.


# Add a CloudWatch log metric filter for billing logs
# resource "aws_cloudwatch_log_metric_filter" "billing_logs" {
#   name           = "EstimatedChargesFilter"
#   log_group_name = "/aws/billing"
#   pattern        = "{ $.EstimatedCharges > 0 }"
#   metric_transformation {
#     name      = "EstimatedChargesMetric"
#     namespace = "AWS/Billing"
#     value     = "$.EstimatedCharges"
#   }
# }

resource "aws_cloudwatch_log_metric_filter" "billing_logs" {
  name           = "EstimatedChargesFilter"
  log_group_name = "awsBilling" # Ensure this log group exists
  pattern        = "{ $.EstimatedCharges > 0 }"
  metric_transformation {
    name      = "EstimatedChargesMetric"
    namespace = "AWS/Billing"
    value     = "$.EstimatedCharges"
  }

  # Note: Detailed billing logs must be enabled in AWS to use this resource.
}

