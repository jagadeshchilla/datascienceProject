# Multi-stage build for smaller final image
FROM python:3.10-slim as builder

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

# Production stage
FROM python:3.10-slim

# Set working directory
WORKDIR /app

# Install system dependencies needed for runtime
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy Python packages from builder stage
COPY --from=builder /root/.local /root/.local

# Make sure scripts in .local are usable
ENV PATH=/root/.local/bin:$PATH

# Create necessary directories
RUN mkdir -p artifacts/data_ingestion \
    artifacts/data_validation \
    artifacts/data_transformation \
    artifacts/model_trainer \
    artifacts/model_evaluation \
    logs \
    config

# Copy project files
COPY src/ src/
COPY config/ config/
COPY templates/ templates/
COPY main.py .
COPY app.py .
COPY params.yaml .
COPY schema.yaml .

# Set environment variables for DagsHub MLflow
ENV MLFLOW_TRACKING_URI="https://dagshub.com/jagadeshchilla/datascienceProject.mlflow"
ENV MLFLOW_TRACKING_USERNAME="jagadeshchilla"
# Note: MLFLOW_TRACKING_PASSWORD should be set via secrets in CI/CD or docker run command

# Set Flask environment variables
ENV FLASK_APP=app.py
ENV FLASK_ENV=production
ENV PYTHONPATH=/app

# Create a non-root user for security
RUN useradd -m -u 1000 mluser && chown -R mluser:mluser /app
USER mluser

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

# Default command to run the Flask app
CMD ["python", "app.py"]
