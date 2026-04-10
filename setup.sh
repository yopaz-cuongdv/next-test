#!/bin/bash

#=========================================
# CI/CD SETUP SCRIPT
#=========================================

set -e

echo "=== Setting up CI/CD Environment ==="

# 1. Tạo thư mục cần thiết
echo "Creating directories..."
mkdir -p ssl logs/nginx

# 2. Set permissions
echo "Setting permissions..."
chmod +x deploy.sh
chmod 755 ssl logs

# 3. Copy and config docker-compose
echo "Setup docker-compose..."
if [ ! -f "docker-compose.override.yml" ]; then
    cat > docker-compose.override.yml << 'EOF'
# Local override - không commit vào git
version: '3.8'

services:
  nginx:
    ports:
      - "8080:80"  # Đổi port nếu 80 đã được sử dụng

  watchtower:
    enabled: false  # Tắt watchtower ở local
EOF
fi

# 4. Tạo .env file
echo "Creating .env file..."
if [ ! -f ".env" ]; then
    cat > .env << 'EOF'
# Docker Registry
REGISTRY=docker.io/yopaz-cuongdv
IMAGE_NAME=nextjs-app

# App Config
NODE_ENV=production
PORT=3000

# Domain (có thể điền sau)
DOMAIN=your-domain.com
EOF
fi

# 5. Start services
echo "Starting services..."
docker-compose up -d

# 6. Show status
echo ""
echo "=== Services Status ==="
docker-compose ps

echo ""
echo "=== Setup Complete! ==="
echo ""
echo "Next steps:"
echo "1. Cài Jenkins Plugin: Docker, GitHub Integration"
echo "2. Thêm credentials vào Jenkins:"
echo "   - docker-credentials (Docker Hub)"
echo "   - server-ssh-key (SSH key để deploy)"
echo "3. Cấu hình GitHub Webhook để auto-trigger"
echo ""
echo "Commands:"
echo "  ./deploy.sh all      - Full deploy"
echo "  ./deploy.sh deploy   - Deploy containers only"
echo "  ./deploy.sh logs     - View logs"
echo ""
