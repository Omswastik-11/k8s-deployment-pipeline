#!/bin/bash

set -e

echo "🚀 Setting up local Kubernetes development environment..."

# Check if required tools are installed
check_tool() {
    if ! command -v $1 &> /dev/null; then
        echo "❌ $1 is not installed. Please install it first."
        exit 1
    else
        echo "✅ $1 is installed"
    fi
}

echo "Checking required tools..."
check_tool kubectl
check_tool docker
check_tool go

# Check for kind (local or in PATH)
if command -v kind &> /dev/null; then
    echo "✅ kind is installed in PATH"
    KIND_CMD="kind"
elif [ -f "./kind.exe" ]; then
    echo "✅ kind.exe found in current directory"
    # Use full path for Windows compatibility
    KIND_CMD="$(pwd)/kind.exe"
else
    echo "❌ kind is not installed. Please install it first."
    exit 1
fi

# Create KIND cluster
echo "🔧 Creating KIND cluster..."
if $KIND_CMD get clusters | grep -q "dev-cluster"; then
    echo "✅ KIND cluster 'dev-cluster' already exists"
else
    $KIND_CMD create cluster --name dev-cluster --config kind-config.yaml
    echo "✅ KIND cluster 'dev-cluster' created"
fi

# Set kubectl context
kubectl config use-context kind-dev-cluster

# Create namespaces
echo "📁 Creating namespaces..."
kubectl create namespace dev --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace staging --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace prod --dry-run=client -o yaml | kubectl apply -f -

# Load Docker image into KIND cluster
echo "🐳 Building and loading Docker image..."
cd app
docker build -t myapp:dev .
$KIND_CMD load docker-image myapp:dev --name dev-cluster
cd ..

echo "🎯 Deploying to dev environment..."
kubectl apply -k k8s/environments/dev/

# Wait for deployment to be ready
echo "⏳ Waiting for deployment to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/dev-myapp -n dev

echo "🌐 Setting up port forwarding..."
echo "Run the following command to access the application:"
echo "kubectl port-forward svc/dev-myapp 8080:80 -n dev"
echo ""
echo "Then visit: http://localhost:8080"
echo ""
echo "API endpoints:"
echo "- GET  http://localhost:8080/health"
echo "- GET  http://localhost:8080/api/users"
echo "- GET  http://localhost:8080/api/users/1"

echo "✨ Setup complete! Your local Kubernetes development environment is ready."
