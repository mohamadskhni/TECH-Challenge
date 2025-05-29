#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo "Starting pre-GitHub upload tests..."

# Test 1: Check if required tools are installed
echo -e "\n${GREEN}1. Checking required tools...${NC}"
command -v node >/dev/null 2>&1 || { echo -e "${RED}Node.js is not installed${NC}"; exit 1; }
command -v docker >/dev/null 2>&1 || { echo -e "${RED}Docker is not installed${NC}"; exit 1; }
command -v kubectl >/dev/null 2>&1 || { echo -e "${RED}kubectl is not installed${NC}"; exit 1; }
command -v terraform >/dev/null 2>&1 || { echo -e "${RED}Terraform is not installed${NC}"; exit 1; }

# Test 2: Validate service-a
echo -e "\n${GREEN}2. Testing service-a...${NC}"
cd service-a
npm install express
node app.js &
SERVICE_A_PID=$!
sleep 5
curl -s http://localhost:3000/health | grep "healthy" || { echo -e "${RED}service-a health check failed${NC}"; kill $SERVICE_A_PID; exit 1; }
kill $SERVICE_A_PID
cd ..

# Test 3: Validate service-b
echo -e "\n${GREEN}3. Testing service-b...${NC}"
cd service-b
npm install express
node app.js &
SERVICE_B_PID=$!
sleep 5
curl -s http://localhost:3001/health | grep "healthy" || { echo -e "${RED}service-b health check failed${NC}"; kill $SERVICE_B_PID; exit 1; }
kill $SERVICE_B_PID
cd ..

# Test 4: Build Docker images
echo -e "\n${GREEN}4. Building Docker images...${NC}"
docker build -t service-a:latest ./service-a || { echo -e "${RED}service-a Docker build failed${NC}"; exit 1; }
docker build -t service-b:latest ./service-b || { echo -e "${RED}service-b Docker build failed${NC}"; exit 1; }

# Test 5: Validate Kubernetes configurations
echo -e "\n${GREEN}5. Validating Kubernetes configurations...${NC}"
for env in dev stg prod; do
    kubectl apply --dry-run=client -f k8s/$env/namespace.yaml || { echo -e "${RED}K8s validation failed for $env/namespace.yaml${NC}"; exit 1; }
    kubectl apply --dry-run=client -f k8s/$env/service-a-deployment.yaml || { echo -e "${RED}K8s validation failed for $env/service-a-deployment.yaml${NC}"; exit 1; }
    kubectl apply --dry-run=client -f k8s/$env/service-a-service.yaml || { echo -e "${RED}K8s validation failed for $env/service-a-service.yaml${NC}"; exit 1; }
    kubectl apply --dry-run=client -f k8s/$env/service-b-deployment.yaml || { echo -e "${RED}K8s validation failed for $env/service-b-deployment.yaml${NC}"; exit 1; }
    kubectl apply --dry-run=client -f k8s/$env/service-b-service.yaml || { echo -e "${RED}K8s validation failed for $env/service-b-service.yaml${NC}"; exit 1; }
done

# Test 6: Validate Terraform configurations
echo -e "\n${GREEN}6. Validating Terraform configuration...${NC}"
cd terraform
terraform init -backend=false || { echo -e "${RED}Terraform init failed${NC}"; exit 1; }
terraform validate || { echo -e "${RED}Terraform validation failed${NC}"; exit 1; }
cd ..

echo -e "\n${GREEN}All tests passed successfully! Ready for GitHub upload.${NC}"
echo -e "\nNext steps:"
echo "1. git init"
echo "2. git add ."
echo "3. git commit -m 'Initial commit'"
echo "4. git remote add origin <your-github-repo-url>"
echo "5. git push -u origin main"
