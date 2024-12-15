# Define variables for customization
variable "aws_region" {
  description = "The AWS region for setting up resources"
  type        = string
  default     = "us-east-1"
}

variable "sns_topic_name" {
  description = "The name of the SNS topic for billing alerts"
  type        = string
  default     = "billing-alert"
}

variable "alert_thresholds" {
  description = "List of billing thresholds to create alarms for"
  type        = list(number)
  default     = [100, 120] # Default thresholds in USD
}

variable "email_endpoint" {
  description = "The email address to receive billing alerts"
  type        = string
  default     = "rahmansamsor82@gmail.com" # Replace with your email
}

variable "currency" {
  description = "Currency for the billing alert (e.g., USD, EUR, GBP)"
  type        = string
  default     = "USD"
}

variable "environment_tag" {
  description = "Tag to define the environment (e.g., Production, Development)"
  type        = string
  default     = "Production"
}

variable "auto_confirm_subscription" {
  description = "Automatically confirm the SNS email subscription (true/false)"
  type        = bool
  default     = false
}
