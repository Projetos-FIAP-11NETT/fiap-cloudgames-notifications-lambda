variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}


variable "localstack_endpoint" {
  description = "Deprecated; kept for compatibility but not used for real AWS deployments"
  type        = string
  default     = ""
}

# Lambda Configuration
variable "lambda_function_name" {
  description = "Name of the Lambda function"
  type        = string
  default     = "email-function"
}

variable "lambda_runtime" {
  description = "Lambda runtime"
  type        = string
  default     = "dotnet8"
}

variable "lambda_memory_size" {
  description = "Lambda memory size in MB"
  type        = number
  default     = 512
}

variable "lambda_timeout" {
  description = "Lambda timeout in seconds"
  type        = number
  default     = 30
}

variable "lambda_handler" {
  description = "Lambda handler"
  type        = string
  default     = "FiapCloudGames.Notifications.Lambda::FiapCloudGames.Notifications.Lambda.EmailFunction::FunctionHandler"
}

variable "lambda_zip_file" {
  description = "Path to the Lambda function ZIP file"
  type        = string
  default     = "../FiapCloudGames.Notifications.Lambda/publish/function.zip"
}

# IAM Configuration
variable "lambda_role" {
  description = "Name of the IAM role for Lambda"
  type        = string
}

# SQS Configuration
variable "sqs_queue_name" {
  description = "Name of the SQS queue"
  type        = string
  default     = "notification-queue"
}

variable "sqs_batch_size" {
  description = "Batch size for SQS Lambda trigger"
  type        = number
  default     = 1
}

# Environment Variables
variable "lambda_environment_variables" {
  description = "Environment variables for Lambda function"
  type        = map(string)
  default = {
    AWS_REGION = "us-east-1"
  }
}

# SES Configuration
variable "ses_verified_email" {
  description = "Email address to verify in SES"
  type        = string
  default     = "no-reply@fiapcloudgames.local"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "FiapCloudGames"
    Service     = "Notifications"
    Environment = "local"
  }
}
