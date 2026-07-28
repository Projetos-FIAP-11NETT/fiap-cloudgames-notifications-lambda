output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.email_function.arn
}

output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.email_function.function_name
}

output "iam_role_arn" {
  description = "ARN of the IAM role"
  value       = data.aws_iam_role.lab_role.arn
}

output "sqs_queue_url" {
  description = "URL of the SQS queue"
  value       = aws_sqs_queue.notification_queue.url
}

output "sqs_queue_arn" {
  description = "ARN of the SQS queue"
  value       = aws_sqs_queue.notification_queue.arn
}

output "event_source_mapping_uuid" {
  description = "UUID of the Lambda event source mapping"
  value       = aws_lambda_event_source_mapping.sqs_trigger.uuid
}

output "lambda_invocation_command" {
  description = "AWS CLI command to test the Lambda function"
  value       = "aws lambda invoke --function-name ${aws_lambda_function.email_function.function_name} --region=${var.aws_region} /tmp/response.json"
}

output "sqs_send_message_command" {
  description = "AWS CLI command to send a test message to SQS"
  value       = "aws sqs send-message --queue-url ${aws_sqs_queue.notification_queue.url} --message-body '{\"to\":\"test@example.com\",\"subject\":\"Test\",\"body\":\"Test message\"}' --region=${var.aws_region}"
}
