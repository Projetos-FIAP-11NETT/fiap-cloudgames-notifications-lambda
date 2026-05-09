
Write-Host ""
Write-Host "====================================="
Write-Host "Purging messages from sqs queue..."
Write-Host "====================================="

aws sqs purge-queue `
  --queue-url http://localhost:4566/000000000000/minha-fila `
  --endpoint-url=http://localhost:4566 `
  --region us-east-1

Write-Host ""
Write-Host "====================================="
Write-Host "Sending test message to sqs queue..."
Write-Host "====================================="

aws sqs send-message `
  --queue-url http://localhost:4566/000000000000/minha-fila `
  --message-body file://scripts/message.json `
  --endpoint-url=http://localhost:4566 `
  --region us-east-1