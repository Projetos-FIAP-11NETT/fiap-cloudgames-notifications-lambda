#!/bin/bash
# Script para testar a infraestrutura do Terraform

set -e

REGION="${AWS_REGION:-us-east-1}"
ENDPOINT="${LOCALSTACK_ENDPOINT:-http://localhost:4566}"

echo "=================================="
echo "Obtendo outputs do Terraform..."
echo "=================================="

QUEUE_URL=$(terraform output -raw sqs_queue_url)
LAMBDA_FUNCTION=$(terraform output -raw lambda_function_name)
LAMBDA_COMMAND=$(terraform output -raw lambda_invocation_command)
SQS_COMMAND=$(terraform output -raw sqs_send_message_command)

echo "Queue URL: $QUEUE_URL"
echo "Lambda Function: $LAMBDA_FUNCTION"
echo ""

echo "=================================="
echo "1. Enviando mensagem de teste..."
echo "=================================="

aws sqs send-message \
  --queue-url "$QUEUE_URL" \
  --message-body '{"to":"test@example.com","subject":"Test Email","body":"This is a test message from Terraform"}' \
  --endpoint-url="$ENDPOINT" \
  --region="$REGION" \
  --output json

echo ""
echo "✓ Mensagem enviada com sucesso!"
echo ""

echo "=================================="
echo "2. Aguardando processamento..."
echo "=================================="

sleep 2

echo ""
echo "=================================="
echo "3. Verificando atributos da fila..."
echo "=================================="

aws sqs get-queue-attributes \
  --queue-url "$QUEUE_URL" \
  --attribute-names ApproximateNumberOfMessages ApproximateNumberOfMessagesNotVisible \
  --endpoint-url="$ENDPOINT" \
  --region="$REGION" \
  --output table

echo ""
echo "=================================="
echo "Teste completo!"
echo "=================================="
echo ""
echo "Para mais testes, use:"
echo "  $LAMBDA_COMMAND"
echo "  $SQS_COMMAND"
