$ErrorActionPreference = "Stop"

# =====================================
# CONFIG
# =====================================

$FunctionName = "email-function"
$RoleName = "lambda-role"
$QueueName = "minha-fila"
$Region = "us-east-1"
$Endpoint = "http://localhost:4566"

$Handler = "FiapCloudGames.Notifications.Lambda::FiapCloudGames.Notifications.Lambda.EmailFunction::FunctionHandler"

$RoleArn = "arn:aws:iam::000000000000:role/$RoleName"
$QueueArn = "arn:aws:sqs:${Region}:000000000000:${QueueName}"


# =====================================
# PATHS
# =====================================

$ProjectRoot = Split-Path -Parent $PSScriptRoot

$PublishPath = Join-Path $ProjectRoot "publish"
$ZipPath = Join-Path $PublishPath "function.zip"

$TrustPolicyPath = Join-Path $ProjectRoot "trust-policy.json"
$EnvPath = Join-Path $ProjectRoot "env.json"

Set-Location $ProjectRoot

Write-Host ""
Write-Host "====================================="
Write-Host "Cleaning old resources..."
Write-Host "====================================="

# DELETE EVENT SOURCE MAPPINGS
try {

    $MappingsJson = aws lambda list-event-source-mappings `
        --function-name $FunctionName `
        --endpoint-url=$Endpoint `
        --region $Region

    $Mappings = $MappingsJson | ConvertFrom-Json

    foreach ($Mapping in $Mappings.EventSourceMappings) {

        Write-Host "Deleting mapping $($Mapping.UUID)..."

        aws lambda delete-event-source-mapping `
            --uuid $Mapping.UUID `
            --endpoint-url=$Endpoint `
            --region $Region | Out-Null
    }

}
catch {
    Write-Host "No mappings found"
}

# DELETE LAMBDA
try {

    Write-Host "Deleting old lambda..."

    aws lambda delete-function `
        --function-name $FunctionName `
        --endpoint-url=$Endpoint `
        --region $Region 2>$null

}
catch {
    Write-Host "Lambda does not exist"
}

# DELETE QUEUE
try {

    $QueueUrl = aws sqs get-queue-url `
        --queue-name $QueueName `
        --endpoint-url=$Endpoint `
        --region $Region `
        --output text `
        --query QueueUrl

    aws sqs delete-queue `
        --queue-url $QueueUrl `
        --endpoint-url=$Endpoint `
        --region $Region | Out-Null

    Write-Host "Queue deleted"

}
catch {
    Write-Host "Queue does not exist"
}

# =====================================
# BUILD
# =====================================

Write-Host ""
Write-Host "====================================="
Write-Host "Building Lambda..."
Write-Host "====================================="

if (Test-Path $PublishPath) {
    Remove-Item $PublishPath -Recurse -Force
}

dotnet publish `
    -c Release `
    -r linux-x64 `
    /p:GenerateRuntimeConfigurationFiles=true `
    --self-contained false `
    -o publish

if ($LASTEXITCODE -ne 0) {
    throw "Dotnet publish failed"
}

# =====================================
# ZIP
# =====================================

Write-Host ""
Write-Host "====================================="
Write-Host "Creating ZIP..."
Write-Host "====================================="

if (Test-Path $ZipPath) {
    Remove-Item $ZipPath -Force
}

Compress-Archive `
    -Path "$PublishPath\*" `
    -DestinationPath $ZipPath `
    -Force

# =====================================
# IAM ROLE
# =====================================

Write-Host ""
Write-Host "====================================="
Write-Host "Creating IAM Role..."
Write-Host "====================================="

try {

    aws iam get-role `
        --role-name $RoleName `
        --endpoint-url=$Endpoint `
        --region $Region 2>$null | Out-Null

    Write-Host "Role already exists"

}
catch {

    aws iam create-role `
        --role-name $RoleName `
        --assume-role-policy-document file://$TrustPolicyPath `
        --endpoint-url=$Endpoint `
        --region $Region | Out-Null

    Write-Host "Role created"
}

# =====================================
# VERIFY SES EMAIL IDENTITY
# =====================================

Write-Host ""
Write-Host "====================================="
Write-Host "Verifying SES Identity..."
Write-Host "====================================="

aws ses verify-email-identity `
    --email-address no-reply@fiapcloudgames.local `
    --endpoint-url=$Endpoint `
    --region $Region | Out-Null

Write-Host "SES identity verified"

# =====================================
# CREATE LAMBDA
# =====================================

Write-Host ""
Write-Host "====================================="
Write-Host "Creating Lambda..."
Write-Host "====================================="

aws lambda create-function `
    --function-name $FunctionName `
    --runtime dotnet8 `
    --handler $Handler `
    --zip-file fileb://$ZipPath `
    --role $RoleArn `
    --environment file://$EnvPath `
    --timeout 30 `
    --memory-size 512 `
    --endpoint-url=$Endpoint `
    --region $Region `
    --no-cli-pager

# =====================================
# CREATE QUEUE
# =====================================

Write-Host ""
Write-Host "====================================="
Write-Host "Creating Queue..."
Write-Host "====================================="

aws sqs create-queue `
    --queue-name $QueueName `
    --endpoint-url=$Endpoint `
    --region $Region | Out-Null

Write-Host "Queue created"

# =====================================
# CREATE TRIGGER
# =====================================

Write-Host ""
Write-Host "====================================="
Write-Host "Creating Event Source Mapping..."
Write-Host "====================================="

aws lambda create-event-source-mapping `
    --function-name $FunctionName `
    --batch-size 1 `
    --event-source-arn $QueueArn `
    --endpoint-url=$Endpoint `
    --region $Region | Out-Null

Write-Host "Trigger created"

# =====================================
# DONE
# =====================================

Write-Host ""
Write-Host "====================================="
Write-Host "DONE"
Write-Host "====================================="