# Script PowerShell para testar a infraestrutura do Terraform

$ErrorActionPreference = "Stop"

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Obtendo outputs do Terraform..." -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan

$QueueUrl = terraform output -raw sqs_queue_url
$LambdaFunction = terraform output -raw lambda_function_name
$Endpoint = "http://localhost:4566"
$Region = "us-east-1"

Write-Host "Queue URL: $QueueUrl" -ForegroundColor Green
Write-Host "Lambda Function: $LambdaFunction" -ForegroundColor Green
Write-Host ""

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "1. Enviando mensagem de teste..." -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan

$messageBody = @{
    to      = "test@example.com"
    subject = "Test Email"
    body    = "This is a test message from Terraform"
} | ConvertTo-Json

aws sqs send-message `
  --queue-url $QueueUrl `
  --message-body $messageBody `
  --endpoint-url=$Endpoint `
  --region=$Region `
  --output json

Write-Host ""
Write-Host "✓ Mensagem enviada com sucesso!" -ForegroundColor Green
Write-Host ""

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "2. Aguardando processamento..." -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan

Start-Sleep -Seconds 2

Write-Host ""
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "3. Verificando atributos da fila..." -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan

aws sqs get-queue-attributes `
  --queue-url $QueueUrl `
  --attribute-names ApproximateNumberOfMessages ApproximateNumberOfMessagesNotVisible `
  --endpoint-url=$Endpoint `
  --region=$Region `
  --output table

Write-Host ""
Write-Host "==================================" -ForegroundColor Green
Write-Host "Teste completo!" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Green
