# CI/CD Deployment Guide

## Tài liệu triển khai CI/CD hoàn toàn bằng Docker

---

## 📋 Cấu trúc

```
.
├── Jenkinsfile              # Pipeline CI/CD (Docker agent)
├── docker-compose.yml       # Production deployment
├── docker-compose.dev.yml   # Development environment
├── Dockerfile              # Production build
├── Dockerfile.dev          # Development with hot reload
├── nginx.conf              # Nginx reverse proxy
├── deploy.sh               # Deployment script
├── setup.sh                # Initial setup script
└── .dockerignore           # Docker ignore rules
```

---

## 🚀 Quick Start

### 1. Initial Setup

```bash
# Chạy script setup
chmod +x setup.sh
./setup.sh
```

### 2. Manual Deploy

```bash
# Full deployment
./deploy.sh all

# Hoặc từng bước
./deploy.sh code      # Pull code
./deploy.sh build     # Build image
./deploy.sh push      # Push to registry
./deploy.sh deploy    # Deploy containers
./deploy.sh logs      # View logs
```

### 3. Development Mode

```bash
docker-compose -f docker-compose.dev.yml up -d
```

---

## 🔧 Jenkins Setup

### Cài đặt Plugins

```
Manage Jenkins → Plugins → Available:
✓ Docker Pipeline
✓ GitHub Integration
✓ SSH Agent
```

### Tạo Credentials

```
Manage Jenkins → Credentials → Global → Add Credentials

1. docker-credentials:
   - Kind: Username with password
   - ID: docker-credentials
   - Username: Docker Hub username
   - Password: Docker Hub token

2. server-ssh-key:
   - Kind: Secret text
   - ID: server-ssh-key
   - Secret: Private SSH key

3. github-token:
   - Kind: Secret text
   - ID: github-token
   - Secret: GitHub Personal Access Token
```

### Pipeline Configuration

```
Job → Configure:

Pipeline:
✅ Definition: Pipeline script from SCM
SCM: Git
Repository: https://github.com/yopaz-cuongdv/next-test.git
Script Path: Jenkinsfile

Branches to build: main

Build Triggers:
✅ GitHub hook trigger for GITScm polling
```

---

## 🔄 Auto Deploy (Webhook)

### GitHub Webhook

```
GitHub → Repo → Settings → Webhooks → Add webhook

Payload URL: http://<jenkins-ip>:8080/github-webhook/
Content type: application/json
Secret: (optional)
Events:
  ✅ Push events
  ✅ Just the push event

Active: ✅
```

### Poll SCM (Alternative)

```
Job → Configure → Build Triggers:
✅ Poll SCM
Schedule: H/5 * * * *  (Check every 5 minutes)
```

---

## 🐳 Docker Commands

```bash
# Xem status
docker-compose ps

# Xem logs
docker-compose logs -f nextjs-app

# Restart
docker-compose restart

# Stop
docker-compose down

# Update & Deploy
docker-compose pull && docker-compose up -d --force-recreate

# Cleanup old images
docker image prune -a
```

---

## 📊 Monitor

```bash
# Health check
curl http://localhost:3000

# Container stats
docker stats

# Nginx logs
tail -f logs/nginx/access.log
```

---

## 🔐 Security Notes

1. **Đừng commit credentials vào git**
2. **Dùng GitHub Secrets cho sensitive data**
3. **Rotate Docker Hub token thường xuyên**
4. **Enable HTTPS cho production**

---

## 🆘 Troubleshooting

### npm: not found
→ Jenkins đang dùng Docker agent, check `Jenkinsfile`

### Permission denied
→ `chmod +x deploy.sh` hoặc chạy với `sudo`

### Port 80 already in use
→ Edit `docker-compose.override.yml` để đổi port

### Container không start
→ `docker-compose logs nextjs-app` để xem lỗi
