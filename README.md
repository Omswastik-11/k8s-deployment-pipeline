# Multi-Environment Kubernetes Deployment Pipeline

This project demonstrates a complete CI/CD pipeline for deploying a Go web application across multiple environments using Kubernetes.

## Quick Start

1. Clone this repository
2. Run `chmod +x scripts/setup-local.sh && ./scripts/setup-local.sh`
3. Access the application at `http://localhost:8080`

## Architecture

- **Go Application**: Simple REST API with health checks
- **Multi-Environment Setup**: Dev (KIND), Staging (GKE), Production (GKE)
- **Infrastructure as Code**: Kustomize for environment-specific configurations
- **CI/CD Pipeline**: Google Cloud Build integration
- **Local Development**: Skaffold for hot reload development

## API Endpoints

- `GET /health` - Health check endpoint
- `GET /` - Application info
- `GET /api/users` - List all users
- `GET /api/users/{id}` - Get specific user

## Development Workflow

### Local Development
```bash
# Start development with hot reload
skaffold dev

# Or manual deployment
./scripts/deploy.sh dev
```

### Staging Deployment
```bash
./scripts/deploy.sh staging v1.2.3
```

### Production Deployment
```bash
./scripts/deploy.sh prod v1.2.3
```
