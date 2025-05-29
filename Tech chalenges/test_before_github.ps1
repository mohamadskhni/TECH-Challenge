# PowerShell script for testing before GitHub upload

# Colors for output
$Green = "`e[32m"
$Red = "`e[31m"
$Reset = "`e[0m"

Write-Host "Starting pre-GitHub upload tests..."

# Test 1: Check if required tools are installed
Write-Host "`n${Green}1. Checking required tools...${Reset}"
$tools = @("node", "docker", "kubectl", "terraform")
foreach ($tool in $tools) {
    if (!(Get-Command $tool -ErrorAction SilentlyContinue)) {
        Write-Host "${Red}$tool is not installed${Reset}"
        exit 1
    }
}

# Test 2: Validate service-a
Write-Host "`n${Green}2. Testing service-a...${Reset}"
Set-Location service-a
npm install express
Start-Process node -ArgumentList "app.js" -PassThru
Start-Sleep -Seconds 5
$response = Invoke-WebRequest -Uri "http://localhost:3000/health" -UseBasicParsing
if ($response.Content -notmatch "healthy") {
    Write-Host "${Red}service-a health check failed${Reset}"
    Get-Process -Name "node" | Stop-Process
    exit 1
}
Get-Process -Name "node" | Stop-Process
Set-Location ..

# Test 3: Validate service-b
Write-Host "`n${Green}3. Testing service-b...${Reset}"
Set-Location service-b
npm install express
Start-Process node -ArgumentList "app.js" -PassThru
Start-Sleep -Seconds 5
$response = Invoke-WebRequest -Uri "http://localhost:3001/health" -UseBasicParsing
if ($response.Content -notmatch "healthy") {
    Write-Host "${Red}service-b health check failed${Reset}"
    Get-Process -Name "node" | Stop-Process
    exit 1
}
Get-Process -Name "node" | Stop-Process
Set-Location ..

# Test 4: Build Docker images
Write-Host "`n${Green}4. Building Docker images...${Reset}"
docker build -t service-a:latest ./service-a
if ($LASTEXITCODE -ne 0) {
    Write-Host "${Red}service-a Docker build failed${Reset}"
    exit 1
}
docker build -t service-b:latest ./service-b
if ($LASTEXITCODE -ne 0) {
    Write-Host "${Red}service-b Docker build failed${Reset}"
    exit 1
}

# Test 5: Validate Kubernetes configurations
Write-Host "`n${Green}5. Validating Kubernetes configurations...${Reset}"
$environments = @("dev", "stg", "prod")
foreach ($env in $environments) {
    kubectl apply --dry-run=client -f k8s/$env/namespace.yaml
    kubectl apply --dry-run=client -f k8s/$env/service-a-deployment.yaml
    kubectl apply --dry-run=client -f k8s/$env/service-a-service.yaml
    kubectl apply --dry-run=client -f k8s/$env/service-b-deployment.yaml
    kubectl apply --dry-run=client -f k8s/$env/service-b-service.yaml
    if ($LASTEXITCODE -ne 0) {
        Write-Host "${Red}K8s validation failed for $env${Reset}"
        exit 1
    }
}

# Test 6: Validate Terraform configurations
Write-Host "`n${Green}6. Validating Terraform configuration...${Reset}"
Set-Location terraform
terraform init -backend=false
if ($LASTEXITCODE -ne 0) {
    Write-Host "${Red}Terraform init failed${Reset}"
    exit 1
}
terraform validate
if ($LASTEXITCODE -ne 0) {
    Write-Host "${Red}Terraform validation failed${Reset}"
    exit 1
}
Set-Location ..

Write-Host "`n${Green}All tests passed successfully! Ready for GitHub upload.${Reset}"
Write-Host "`nNext steps:"
Write-Host "1. git init"
Write-Host "2. git add ."
Write-Host "3. git commit -m 'Initial commit'"
Write-Host "4. git remote add origin <your-github-repo-url>"
Write-Host "5. git push -u origin main"
