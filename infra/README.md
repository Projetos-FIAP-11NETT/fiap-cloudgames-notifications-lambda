# Infraestrutura Terraform - Lambda Notifications

Este diretório contém a configuração do Terraform para provisionar a infraestrutura da Lambda de notificações no LocalStack.

## Pré-requisitos

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- [AWS CLI](https://aws.amazon.com/cli/)
- [LocalStack](https://localstack.cloud/) em execução em `http://localhost:4566`
- Lambda function zipada em `../FiapCloudGames.Notifications.Lambda/publish/function.zip`

## Estrutura de Arquivos

- **provider.tf** - Configuração do provider AWS e endpoints do LocalStack
- **variables.tf** - Definição de todas as variáveis do Terraform
- **terraform.tfvars** - Valores padrão para as variáveis
- **main.tf** - Recursos principais (IAM, Lambda, SQS, Event Source Mapping, SES)
- **outputs.tf** - Outputs úteis para consultar after apply
- **.gitignore** - Arquivo .gitignore para git

## Como Usar

### 1. Build da Lambda

Primeiro, construa o pacote da Lambda:

```bash
cd ../FiapCloudGames.Notifications.Lambda
dotnet publish -c Release -r linux-x64 /p:GenerateRuntimeConfigurationFiles=true --self-contained false -o publish
Compress-Archive -Path "publish\*" -DestinationPath "publish/function.zip" -Force
```

### 2. Inicializar Terraform

```bash
terraform init
```

Isso fará o download dos providers necessários e criará o arquivo `.terraform.lock.hcl`.

### 3. Validar Configuração

```bash
terraform validate
```

### 4. Preview das Alterações

```bash
terraform plan
```

### 5. Aplicar a Configuração

```bash
terraform apply
```

Quando solicitado, confirme digitando `yes`.

### 6. Verificar Outputs

```bash
terraform output
```

Você verá os ARNs, URLs e comandos úteis para testar.

### 7. Destruir Recursos (quando necessário)

```bash
terraform destroy
```

Confirme digitando `yes`.

## Variáveis Customizáveis

Você pode customizar as variáveis editando `terraform.tfvars` ou passando valores na linha de comando:

```bash
# Mudar o endpoint do LocalStack
terraform apply -var="localstack_endpoint=http://localstack:4566"

# Mudar tamanho de memória da Lambda
terraform apply -var="lambda_memory_size=1024"

# Mudar região
terraform apply -var="aws_region=sa-east-1"
```

## Testando a Infraestrutura

### Enviar mensagem para a fila SQS

```bash
# Obter a URL da fila
QUEUE_URL=$(terraform output -raw sqs_queue_url)

# Enviar mensagem
aws sqs send-message \
  --queue-url $QUEUE_URL \
  --message-body '{"to":"test@example.com","subject":"Test","body":"Test message"}' \
  --endpoint-url=http://localhost:4566 \
  --region=us-east-1
```

### Invocar Lambda diretamente

```bash
# Usar o comando gerado pelo Terraform
$(terraform output -raw lambda_invocation_command)
```

### Ver logs da Lambda

```bash
aws logs tail /aws/lambda/email-function --follow --endpoint-url=http://localhost:4566 --region=us-east-1
```

## Comparação com Script PowerShell

Este Terraform replica todas as operações do script `deploy-local-lambda.ps1`:

| Operação | PowerShell Script | Terraform |
|----------|------------------|-----------|
| Criar Role IAM | ✓ | ✓ |
| Criar Lambda | ✓ | ✓ |
| Criar Fila SQS | ✓ | ✓ |
| Criar Event Source Mapping | ✓ | ✓ |
| Verificar Email SES | ✓ | ✓ |
| Definir variáveis de ambiente | ✓ | ✓ |
| Limpeza de recursos antigos | Manual | `terraform destroy` |

## Troubleshooting

### Erro: "Unable to locate credentials"

Isso é normal no LocalStack. A configuração do provider já trata isso com `skip_credentials_validation = true`.

### Erro: "ZIP file not found"

Certifique-se que:
1. O diretório `publish` existe
2. O arquivo `function.zip` foi criado com sucesso
3. O caminho em `terraform.tfvars` está correto

### Erro: "Connection refused"

Certifique-se que:
1. LocalStack está rodando em `http://localhost:4566`
2. Você pode acessar: `curl http://localhost:4566`

## Próximas Etapas

- Para ambientes de produção, considere:
  - Usar um backend remoto (S3, Terraform Cloud)
  - Implementar variações de ambiente (dev, staging, prod)
  - Adicionar mais políticas IAM específicas
  - Configurar CloudWatch alarms
  - Usar modules Terraform para reutilização
