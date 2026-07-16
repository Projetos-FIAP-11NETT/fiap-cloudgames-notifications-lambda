# =====================================================
# SQS Queue
# =====================================================

resource "aws_sqs_queue" "notification_queue" {
  name = var.sqs_queue_name

  tags = var.tags
}

# =====================================================
# Lambda Function
# =====================================================

resource "aws_lambda_function" "email_function" {
  filename         = var.lambda_zip_file
  function_name    = var.lambda_function_name
  role_arn         = var.lambda_role.arn
  handler          = var.lambda_handler
  runtime          = var.lambda_runtime
  timeout          = var.lambda_timeout
  memory_size      = var.lambda_memory_size
  source_code_hash = filebase64sha256(var.lambda_zip_file)

  environment {
    variables = var.lambda_environment_variables
  }

  tags = var.tags
}

# =====================================================
# Lambda Event Source Mapping (SQS trigger)
# =====================================================

resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  event_source_arn = aws_sqs_queue.notification_queue.arn
  function_name    = aws_lambda_function.email_function.function_name
  batch_size       = var.sqs_batch_size

  depends_on = [
    aws_lambda_function.email_function
  ]
}

# =====================================================
# SES Email Verification
# =====================================================

resource "aws_ses_email_identity" "notification_email" {
  email = var.ses_verified_email
}
