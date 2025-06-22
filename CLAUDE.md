# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a self-hosted n8n deployment using Docker Compose. n8n is a workflow automation tool that allows users to create complex automation workflows through a visual interface.

## Architecture

- **Containerized Deployment**: Uses Docker Compose to orchestrate the n8n service
- **Database Options**: Configured to support both SQLite (default) and PostgreSQL
- **Environment-based Configuration**: Uses `.env` file for environment variables
- **LangSmith Integration**: Configured for workflow tracing and monitoring via LangChain

## Common Commands

### Docker Operations
```bash
# Start the n8n service
docker-compose up -d

# Stop the service
docker-compose down

# View logs
docker-compose logs -f n8n

# Restart the service
docker-compose restart n8n

# Pull latest n8n image
docker-compose pull
```

### Environment Setup
```bash
# Copy example environment file
cp .env.example .env

# Edit environment variables (especially LANGSMITH_API_KEY)
# Required for LangSmith integration
```

## Configuration Details

### Database Configuration
- **Default**: SQLite database stored in Docker volume `data:/home/node/.n8n`
- **Alternative**: PostgreSQL setup available (commented out in docker-compose.yml)
- To switch to PostgreSQL, uncomment the database service and update environment variables

### Port Configuration
- n8n web interface accessible on `localhost:5678`
- Default timezone set to `America/Lima`

### Environment Variables
Key variables in `.env`:
- `LANGSMITH_API_KEY`: Required for LangSmith tracing integration
- `LANGSMITH_PROJECT`: Project name for LangSmith (default: "n8n")
- `LANGSMITH_ENDPOINT`: LangSmith API endpoint
- `LANGSMITH_TRACING_V2`: Enable LangSmith v2 tracing

## Data Persistence

- n8n data persists in Docker volume `data`
- Workflows, credentials, and settings are preserved between container restarts
- Database file location: `/home/node/.n8n/database.sqlite` (if using SQLite)