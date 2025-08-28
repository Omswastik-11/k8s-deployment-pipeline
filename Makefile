.PHONY: help build test clean deploy-dev deploy-staging deploy-prod setup-local

# Default target
help:
	@echo "Available commands:"
	@echo "  build         - Build the Go application"
	@echo "  test          - Run Go tests"
	@echo "  clean         - Clean build artifacts"
	@echo "  deploy-dev    - Deploy to development environment"
	@echo "  deploy-staging- Deploy to staging environment"
	@echo "  deploy-prod   - Deploy to production environment"
	@echo "  setup-local   - Set up local development environment"
	@echo "  skaffold-dev  - Start Skaffold development mode"

# Build the application
build:
	cd app && go build -o main .

# Run tests
test:
	cd app && go test -v ./...

# Clean build artifacts
clean:
	cd app && rm -f main
	docker rmi myapp:latest 2>/dev/null || true

# Deploy to development
deploy-dev:
	./scripts/deploy.sh dev

# Deploy to staging
deploy-staging:
	./scripts/deploy.sh staging

# Deploy to production
deploy-prod:
	./scripts/deploy.sh prod

# Setup local environment
setup-local:
	chmod +x scripts/setup-local.sh
	./scripts/setup-local.sh

# Start Skaffold development
skaffold-dev:
	skaffold dev
