#!/bin/bash

#=========================================
# CI/CD DEPLOYMENT SCRIPT
#=========================================

set -e  # Exit on error

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Config
REGISTRY="docker.io/yopaz-cuongdv"
IMAGE_NAME="nextjs-app"
DEPLOY_PATH="/var/www/AI/nextjs-base"

echo -e "${GREEN}=== CI/CD Deployment Script ===${NC}"

# Function: Pull latest code
pull_code() {
    echo -e "${YELLOW}Pulling latest code...${NC}"
    cd $DEPLOY_PATH
    git pull origin main
}

# Function: Build Docker image
build_image() {
    echo -e "${YELLOW}Building Docker image...${NC}"
    cd $DEPLOY_PATH
    GIT_SHORT=$(git rev-parse --short HEAD)
    docker build -t ${REGISTRY}/${IMAGE_NAME}:${GIT_SHORT} .
    docker tag ${REGISTRY}/${IMAGE_NAME}:${GIT_SHORT} ${REGISTRY}/${IMAGE_NAME}:latest
}

# Function: Push to registry
push_image() {
    echo -e "${YELLOW}Pushing to registry...${NC}"
    docker push ${REGISTRY}/${IMAGE_NAME}:latest
}

# Function: Deploy containers
deploy_containers() {
    echo -e "${YELLOW}Deploying containers...${NC}"
    cd $DEPLOY_PATH

    # Pull latest image
    docker pull ${REGISTRY}/${IMAGE_NAME}:latest

    # Restart containers
    docker-compose down
    docker-compose up -d

    # Wait for health check
    echo -e "${YELLOW}Waiting for app to be healthy...${NC}"
    sleep 10

    # Check status
    docker-compose ps
}

# Function: Show logs
show_logs() {
    echo -e "${YELLOW}Recent logs:${NC}"
    docker-compose logs --tail=50 nextjs-app
}

# Main deployment flow
main() {
    case "${1:-all}" in
        "code")
            pull_code
            ;;
        "build")
            build_image
            ;;
        "push")
            push_image
            ;;
        "deploy")
            deploy_containers
            ;;
        "logs")
            show_logs
            ;;
        "all")
            pull_code
            build_image
            push_image
            deploy_containers
            show_logs
            ;;
        *)
            echo "Usage: $0 [code|build|push|deploy|logs|all]"
            exit 1
            ;;
    esac

    echo -e "${GREEN}=== Deployment Complete! ===${NC}"
}

main "$@"
