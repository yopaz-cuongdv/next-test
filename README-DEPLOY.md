# CI/CD Deployment Guide

## 📋 Cấu trúc

```
.
├── Jenkinsfile          # Pipeline CI/CD
├── docker-compose.yml   # Cả Dev & Prod (gộp chung)
├── Dockerfile           # Đa dụng (Dev + Prod)
└── nginx.conf           # Nginx reverse proxy
```

---

## 🚀 Quick Start

### Development (hot reload)
```bash
docker-compose --profile dev up -d
```

### Production
```bash
docker-compose up -d
```

---

## 🔧 Jenkins Setup

### 1. Cài đặt Plugins
```
Manage Jenkins → Plugins → Available:
✓ Docker Pipeline
✓ GitHub Integration
```

### 2. Tạo Credentials
```
Manage Jenkins → Credentials → Global → Add Credentials

1. github-token:
   - Kind: Secret text
   - ID: github-token
   - Secret: GitHub Personal Access Token
```

### 3. Pipeline Configuration
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

## 🐳 Docker Commands

```bash
# Production
docker-compose up -d --build

# Development
docker-compose --profile dev up -d

# Stop
docker-compose down

# View logs
docker-compose logs -f

# Restart
docker-compose restart
```

---

## 🆘 Troubleshooting

### Port 3000 already in use
```bash
docker-compose down
docker-compose up -d
```

### Need hot reload?
```bash
docker-compose --profile dev up -d
```

### Clean restart
```bash
docker-compose down -v
docker-compose up -d --build
```
