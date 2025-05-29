# Microservices Project

This project consists of two microservices (service-a and service-b) with Kubernetes deployments for dev, staging, and production environments, managed through Terraform.

## Project Structure

```
.
├── k8s/                    # Kubernetes configurations
│   ├── dev/               # Development environment
│   ├── stg/               # Staging environment
│   └── prod/              # Production environment
├── service-a/             # Service A (Node.js application)
├── service-b/             # Service B (Node.js application)
├── terraform/             # Infrastructure as Code
└── test_before_github.sh  # Test script for validation
```

## Services

### Service A
- Simple Express.js application
- Runs on port 3000
- Endpoints:
  - `/`: Returns "Hello from Service A!"
  - `/health`: Returns health status

### Service B
- Simple Express.js application
- Runs on port 3001
- Endpoints:
  - `/`: Returns "Hello from Service B!"
  - `/health`: Returns health status

## Prerequisites

Before running the tests or deploying, ensure you have the following installed:
- Node.js
- Docker
- kubectl
- Terraform

## Testing Before GitHub Upload

A test script is provided to validate all components before uploading to GitHub:

```bash
# Make the script executable
chmod +x test_before_github.sh

# Run the test script
./test_before_github.sh
```

The script performs the following validations:
1. Checks if required tools are installed
2. Tests service-a functionality
3. Tests service-b functionality
4. Builds Docker images
5. Validates Kubernetes configurations
6. Validates Terraform configurations

## Deployment

### Local Development
1. Start service-a:
```bash
cd service-a
npm install
node app.js
```

2. Start service-b:
```bash
cd service-b
npm install
node app.js
```

### Docker Build
```bash
# Build service-a
docker build -t service-a:latest ./service-a

# Build service-b
docker build -t service-b:latest ./service-b
```

### Kubernetes Deployment
```bash
# Apply configurations for desired environment (dev/stg/prod)
kubectl apply -f k8s/dev/
```

### Infrastructure Setup
```bash
cd terraform
terraform init
terraform plan
terraform apply
```

## Contributing
1. Run the test script before committing:
```bash
./test_before_github.sh
```
2. If all tests pass, proceed with git commands:
```bash
git add .
git commit -m "Your commit message"
git push
