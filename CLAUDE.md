# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a self-hosted n8n deployment using Docker Compose with Traefik reverse proxy. n8n is a workflow automation tool that allows users to create complex automation workflows through a visual interface. The setup includes SSL/TLS termination, automatic certificate management, and production-ready configuration.

## Architecture

- **Containerized Deployment**: Uses Docker Compose to orchestrate n8n and Traefik services
- **Reverse Proxy**: Traefik handles SSL termination and routing with automatic Let's Encrypt certificates
- **Database Options**: Configured to support both SQLite (default) and PostgreSQL
- **Environment-based Configuration**: Uses `.env` file for environment variables
- **LangSmith Integration**: Configured for workflow tracing and monitoring via LangChain
- **File Access**: Local files mounted via `./local-files` directory for workflow processing

## Common Commands

### Docker Operations
```bash
# Start all services (n8n + Traefik)
docker-compose up -d

# Stop all services
docker-compose down

# View logs
docker-compose logs -f n8n
docker-compose logs -f traefik

# Restart specific service
docker-compose restart n8n
docker-compose restart traefik

# Build and pull latest images
docker-compose build --pull
docker-compose pull
```

### Environment Setup
```bash
# Copy example environment file
cp .env.example .env

# Edit environment variables
# Required for production: DOMAIN_NAME, SUBDOMAIN, SSL_EMAIL
# Required for LangSmith: LANGSMITH_API_KEY

# Create required Docker volumes
docker volume create n8n_data
docker volume create traefik_data
```

## Configuration Details

### Database Configuration
- **Default**: SQLite database stored in Docker volume `n8n_data:/home/node/.n8n`
- **Alternative**: PostgreSQL setup available (commented out in docker-compose.yml)
- To switch to PostgreSQL, uncomment the database service and update environment variables

### Port Configuration
- **Local Development**: n8n web interface accessible on `localhost:5678`
- **Production**: n8n accessible via `https://${SUBDOMAIN}.${DOMAIN_NAME}`
- **Traefik**: Ports 80/443 for HTTP/HTTPS traffic
- Default timezone set to `America/Lima`

### Environment Variables
Key variables in `.env`:

**n8n Configuration:**
- `DOMAIN_NAME`: Your domain name (required for production)
- `SUBDOMAIN`: Subdomain for n8n (e.g., "n8n")
- `GENERIC_TIMEZONE`: Timezone for n8n (default: "America/Lima")
- `TZ`: System timezone (default: "America/Lima")
- `SSL_EMAIL`: Email for Let's Encrypt certificates (required for SSL)

**LangSmith Integration:**
- `LANGSMITH_API_KEY`: Required for LangSmith tracing integration
- `LANGSMITH_PROJECT`: Project name for LangSmith (default: "n8n")
- `LANGSMITH_ENDPOINT`: LangSmith API endpoint
- `LANGSMITH_TRACING_V2`: Enable LangSmith v2 tracing

## Data Persistence

- n8n data persists in Docker volume `n8n_data`
- SSL certificates and Traefik config persist in Docker volume `traefik_data`
- Local files accessible via `./local-files` directory (mounted as `/files` in container)
- Workflows, credentials, and settings are preserved between container restarts
- Database file location: `/home/node/.n8n/database.sqlite` (if using SQLite)

## Additional Commands

### SSL and Domain Management
```bash
# Check SSL certificate status
docker-compose exec traefik ls -la /letsencrypt/

# Test HTTPS connection
curl -I https://${SUBDOMAIN}.${DOMAIN_NAME}

# View Traefik dashboard (if API enabled)
open http://localhost:8080
```

### File Management
```bash
# Create local files directory for n8n workflows
mkdir -p ./local-files

# Files in ./local-files are accessible in n8n at /files/
# Example: ./local-files/data.csv becomes /files/data.csv in n8n
```

### Backup Operations
```bash
# Backup n8n data
docker run --rm -v n8n_data:/data -v $(pwd):/backup alpine tar czf /backup/n8n-backup.tar.gz -C /data .

# Backup Traefik data (SSL certificates)
docker run --rm -v traefik_data:/data -v $(pwd):/backup alpine tar czf /backup/traefik-backup.tar.gz -C /data .
```