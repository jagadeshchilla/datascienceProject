# Docker Deployment Guide for Data Science Project

This guide explains how to containerize and deploy your data science project using Docker, including MLflow tracking with DagsHub integration.

## 🐳 Quick Start

### Prerequisites
- Docker installed on your system
- DagsHub account and access token
- Git repository set up

### 1. Set up DagsHub Token

**Windows (Easy Setup):**
```batch
setup-env.bat
```

**Manual Setup:**
```bash
# Linux/Mac
export DAGSHUB_TOKEN=your_dagshub_token_here

# Windows
set DAGSHUB_TOKEN=your_dagshub_token_here
```

### 2. Build and Run (Easy Way)

**Linux/Mac:**
```bash
./run.sh run
```

**Windows:**
```batch
run.bat run
```

**Alternative Windows Testing:**
```batch
test-docker-local.bat
```

The application will be available at: http://localhost:8080

## 📋 Available Commands

### Using run.sh (Linux/Mac) or run.bat (Windows)

```bash
# Build Docker image
./run.sh build
run.bat build

# Run container (builds if needed)
./run.sh run
run.bat run

# View logs
./run.sh logs
run.bat logs

# Stop container
./run.sh stop
run.bat stop

# Clean up (remove container and image)
./run.sh clean
run.bat clean
```

## 🛠️ Manual Docker Commands

### Build Image
```bash
docker build -t datascienceproject:latest .
```

### Run Container
```bash
docker run -d \
  --name datascienceproject-container \
  -p 8080:8080 \
  -e MLFLOW_TRACKING_PASSWORD="your_dagshub_token" \
  -v "$(pwd)/artifacts:/app/artifacts" \
  -v "$(pwd)/logs:/app/logs" \
  datascienceproject:latest
```

### Using Docker Compose
```bash
# Set environment variable
export DAGSHUB_TOKEN=your_dagshub_token_here

# Start services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

## 🌐 Application Endpoints

- **Home Page**: http://localhost:8080/
- **Health Check**: http://localhost:8080/health (GET)
- **Prediction**: http://localhost:8080/predict (POST)
- **Training**: http://localhost:8080/train (GET)

## 🔧 Environment Variables

| Variable | Description | Required | Default |
|----------|-------------|----------|---------|
| `MLFLOW_TRACKING_URI` | DagsHub MLflow server URL | No | https://dagshub.com/jagadeshchilla/datascienceProject.mlflow |
| `MLFLOW_TRACKING_USERNAME` | DagsHub username | No | jagadeshchilla |
| `MLFLOW_TRACKING_PASSWORD` | DagsHub access token | Yes | - |
| `FLASK_ENV` | Flask environment | No | production |

## 📦 CI/CD with GitHub Actions

### Required GitHub Secrets

Set up these secrets in your GitHub repository:

1. **DOCKERHUB_USERNAME**: Your Docker Hub username
2. **DOCKERHUB_TOKEN**: Your Docker Hub access token
3. **DAGSHUB_TOKEN**: Your DagsHub access token

### Workflow Triggers

The CI/CD pipeline triggers on:
- Push to `main` or `develop` branches
- Pull requests to `main`
- Git tags starting with `v*`

### Pipeline Stages

1. **Test**: 
   - Code linting with flake8
   - Import structure verification
   - Dependency validation

2. **Build & Push**:
   - Multi-platform Docker build (amd64, arm64)
   - Push to Docker Hub with multiple tags
   - Caching for faster builds

3. **Deploy Test**:
   - Pull and test the built image
   - Health check verification
   - API endpoint testing

4. **Notify**:
   - Success/failure notifications

## 🔧 Docker Image Details

### Base Image
- `python:3.10-slim` (optimized for size and security)

### Features
- Multi-stage build for smaller image size
- Non-root user for security
- Health checks included
- Volume mounts for data persistence
- Pre-configured DagsHub MLflow integration

### Image Tags

The CI/CD pipeline creates multiple tags:
- `latest` (for main branch)
- `main` (for main branch)
- `develop` (for develop branch)
- `v1.0.0` (for version tags)
- `main-abc123` (for commit SHA)

## 🚀 Deployment Options

### 1. Local Development
```bash
# Using Docker Compose
docker-compose up -d
```

### 2. Production Deployment
```bash
# Pull from Docker Hub
docker pull yourusername/datascienceproject:latest

# Run with production settings
docker run -d \
  --name datascienceproject \
  --restart unless-stopped \
  -p 80:8080 \
  -e MLFLOW_TRACKING_PASSWORD="$DAGSHUB_TOKEN" \
  -v /data/artifacts:/app/artifacts \
  -v /data/logs:/app/logs \
  yourusername/datascienceproject:latest
```

### 3. Cloud Deployment

**AWS ECS, Azure Container Instances, or Google Cloud Run**
- Use the public Docker image: `yourusername/datascienceproject:latest`
- Set environment variables through cloud platform
- Configure load balancer for high availability

## 🔍 Troubleshooting

### Common Issues

1. **DAGSHUB_TOKEN not set**
   ```
   Error: DAGSHUB_TOKEN environment variable is not set!
   ```
   **Solution**: Set the environment variable with your DagsHub token

2. **Port already in use**
   ```
   Error: Port 8080 is already in use
   ```
   **Solution**: Stop existing container or use different port:
   ```bash
   docker run -p 8081:8080 ...
   ```

3. **Permission denied on artifacts/logs**
   ```
   Error: Permission denied
   ```
   **Solution**: Ensure directories are writable:
   ```bash
   chmod 755 artifacts logs
   ```

### Debug Container
```bash
# Run container interactively
docker run -it --rm datascienceproject:latest /bin/bash

# Check running processes
docker exec -it datascienceproject-container ps aux

# View detailed logs
docker logs --details datascienceproject-container
```

## 📊 Monitoring

### Health Checks
The container includes automatic health checks:
- **Endpoint**: http://localhost:8080/health
- **Interval**: 30 seconds
- **Timeout**: 3 seconds
- **Retries**: 3
- **Start Period**: 10 seconds

### Logs
```bash
# Follow logs in real-time
docker logs -f datascienceproject-container

# View last 100 lines
docker logs --tail 100 datascienceproject-container
```

## 🔐 Security Considerations

1. **Non-root user**: Container runs as non-root user (mluser)
2. **Secret management**: Use Docker secrets or environment variables
3. **Network security**: Configure firewall rules appropriately
4. **Image scanning**: Regular vulnerability scans recommended

## 🚀 Performance Optimization

1. **Multi-stage builds**: Reduces image size by ~60%
2. **Layer caching**: Docker layer caching in CI/CD
3. **Volume mounts**: Persistent data storage
4. **Health checks**: Automatic restart on failure

## 📝 Next Steps

1. **Production Setup**: Configure reverse proxy (nginx/traefik)
2. **Scaling**: Use Docker Swarm or Kubernetes for scaling
3. **Monitoring**: Integrate with Prometheus/Grafana
4. **Backup**: Set up automated backup for artifacts/logs

---

For more information, visit the [project repository](https://github.com/yourusername/datascienceproject) or [DagsHub documentation](https://dagshub.com/docs/). 