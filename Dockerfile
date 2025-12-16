FROM python:3.11-slim

# Install jq for JSON processing
RUN apt-get update && apt-get install -y --no-install-recommends \
    jq \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install Docker CLI
RUN curl -fsSL https://get.docker.com -o get-docker.sh && \
    sh get-docker.sh && \
    rm get-docker.sh

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py gunicorn.conf.py ./

EXPOSE 5000

# Production server avec Gunicorn
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "1", "--worker-class", "sync", "--threads", "2", "app:app"]
