# Automated Multi-Environment Service Deployment and Monitoring

## Overview
This project automates the deployment of two microservices (`service-a` and `service-b`) across three Kubernetes environments: `dev`, `stg`, and `prod`. It uses Docker for containerization, Kubernetes (Minikube) for orchestration, Terraform for infrastructure provisioning, GitHub Actions for CI/CD pipeline, and Kuma Uptime for monitoring.

## Prerequisites
- Docker
- Minikube
- kubectl
- Terraform
- GitHub CLI and GitHub Actions Runner (for local runner)
- Node.js and npm (for services)
- Kuma CLI (for installing Kuma service mesh)

## Setup Instructions

### 1. Start Minikube
```bash
minikube start
```

### 2. Configure kubectl context
Ensure kubectl is configured to use Minikube:
```bash
kubectl config use-context minikube
```

### 3. Build Docker images
Use Minikube's Docker daemon to build images:
```bash
eval $(minikube docker-env)
docker build -t service-a:latest ./service-a
docker build -t service-b:latest ./service-b
```

### 4. Provision Kubernetes namespaces using Terraform
```bash
cd terraform
terraform init
terraform apply
```

### 5. Install Kuma service mesh
```bash
kumactl install control-plane | kubectl apply -f -
kubectl wait --for=condition=available deployment/kuma-control-plane -n kuma-system
```

### 6. Enable Kuma Uptime monitoring
Follow Kuma documentation to enable Kuma Uptime and configure monitoring for the services in all namespaces.

### 7. Deploy services using GitHub Actions local runner
- Set up GitHub Actions runner locally.
- Run the workflow `.github/workflows/deploy.yml` to build and deploy services sequentially to dev, stg, and prod.

### 8. Access Kuma dashboard
Forward Kuma dashboard port and access it locally:
```bash
kubectl port-forward -n kuma-system svc/kuma-control-plane 5681:5681
```
Open http://localhost:5681 in your browser.

## Verification
- Check service endpoints in each namespace:
```bash
kubectl get pods -n dev
kubectl get pods -n stg
kubectl get pods -n prod
```
- Access service health endpoints via port-forward or ingress.
- Monitor service uptime and availability via Kuma dashboard.

## Notes
- Adjust the CI/CD pipeline and Terraform scripts as needed for your local environment.
- This setup assumes Minikube is running locally and accessible.

## License
MIT License
