#!/bin/bash

set -e

ENVIRONMENT=${1:-dev}
VERSION=${2:-latest}

echo "🚀 Deploying to $ENVIRONMENT environment with version $VERSION..."

# Validate environment
case $ENVIRONMENT in
    dev|staging|prod)
        echo "✅ Valid environment: $ENVIRONMENT"
        ;;
    *)
        echo "❌ Invalid environment: $ENVIRONMENT"
        echo "Usage: $0 [dev|staging|prod] [version]"
        exit 1
        ;;
esac

# Build Docker image
echo "🐳 Building Docker image..."
cd app
docker build -t myapp:$VERSION .

# Handle different deployment targets
if [ "$ENVIRONMENT" = "dev" ]; then
    # Check for kind (local or in PATH)
    if command -v kind &> /dev/null; then
        KIND_CMD="kind"
    elif [ -f "./kind.exe" ]; then
        # Use full path for Windows compatibility
        KIND_CMD="$(pwd)/kind.exe"
    else
        echo "❌ kind is not available. Please install it first."
        exit 1
    fi
    
    echo "📦 Loading image into KIND cluster..."
    $KIND_CMD load docker-image myapp:$VERSION --name dev-cluster

    # Set kubectl context for KIND
    kubectl config use-context kind-dev-cluster

    # Create namespace if it doesn't exist
    kubectl create namespace $ENVIRONMENT --dry-run=client -o yaml | kubectl apply -f -
else
    echo "📦 Pushing image to registry..."
    # For staging/prod, you would push to a real registry
    # docker tag myapp:$VERSION gcr.io/YOUR_PROJECT/myapp:$VERSION
    # docker push gcr.io/YOUR_PROJECT/myapp:$VERSION

    # Set kubectl context for GKE
    # kubectl config use-context gke_YOUR_PROJECT_${ENVIRONMENT}-cluster_us-central1-a
fi

cd ..

# Update kustomization with new image version
echo "🔧 Updating image version in kustomization..."
cd k8s/environments/$ENVIRONMENT
kustomize edit set image myapp=myapp:$VERSION
cd ../../..

# Deploy using kustomize
echo "🎯 Deploying to $ENVIRONMENT..."
kubectl apply -k k8s/environments/$ENVIRONMENT/

# Wait for rollout to complete
echo "⏳ Waiting for deployment to complete..."
DEPLOYMENT_NAME="${ENVIRONMENT}-myapp"
if [ "$ENVIRONMENT" = "dev" ]; then
    kubectl wait --for=condition=available --timeout=300s deployment/$DEPLOYMENT_NAME -n $ENVIRONMENT
else
    kubectl rollout status deployment/$DEPLOYMENT_NAME -n $ENVIRONMENT --timeout=300s
fi

# Get service info
echo "📋 Deployment completed! Service information:"
kubectl get svc -n $ENVIRONMENT -l app=myapp

if [ "$ENVIRONMENT" = "dev" ]; then
    echo ""
    echo "🌐 To access the application locally:"
    echo "kubectl port-forward svc/$DEPLOYMENT_NAME 8080:80 -n $ENVIRONMENT"
fi

echo "✅ Deployment to $ENVIRONMENT completed successfully!"
