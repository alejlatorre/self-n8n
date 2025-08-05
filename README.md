# self-n8n

A self-hosted n8n workflow automation platform deployment using Docker Compose, configured with LangSmith integration for advanced workflow tracing and monitoring.

## Overview

This project provides a containerized deployment of n8n, a powerful workflow automation tool that allows you to create complex automation workflows through an intuitive visual interface. The setup includes optional LangSmith integration for workflow tracing and monitoring capabilities.

## Features

- 🐳 **Containerized Deployment**: Easy setup using Docker Compose with custom n8n build
- 🔧 **Enhanced n8n**: Pre-configured with @xmldom/xmldom for XML processing workflows
- 🗄️ **Flexible Database Options**: Supports both SQLite (default) and PostgreSQL
- 📊 **LangSmith Integration**: Advanced workflow tracing and monitoring via LangChain
- 🔄 **Data Persistence**: Workflows and data persist between container restarts
- ⚙️ **Environment-based Configuration**: Easy configuration through environment variables
- 🔒 **SSL/TLS Support**: Integrated Traefik reverse proxy with automatic Let's Encrypt certificates
- 🌐 **Domain Configuration**: Production-ready setup with custom domain support
- 📁 **Local File Access**: Mount local files for workflow processing

## Prerequisites

- Docker and Docker Compose installed on your system
- Basic understanding of n8n workflow automation

## Quick Start

### Automated Setup (Recommended)

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd self-n8n
   ```

2. **Run the initialization script**
   ```bash
   ./scripts/init.sh
   ```

   This script will automatically:
   - Check Docker prerequisites
   - Create the required Docker volume (`n8n_data`)
   - Set up environment configuration
   - Start all services
   - Provide helpful next steps

3. **Access n8n**
   Open your browser and navigate to: `http://localhost:5678`

### Manual Setup

If you prefer to set up manually:

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd self-n8n
   ```

2. **Create the external Docker volume**
   ```bash
   docker volume create n8n_data
   ```

3. **Set up environment variables**
   ```bash
   # Create your environment file
   cp .env.example .env
   
   # Edit the .env file with your configuration
   # Required: LANGSMITH_API_KEY for LangSmith integration
   ```

4. **Start the services**
   ```bash
   docker-compose up -d
   ```

5. **Access n8n**
   Open your browser and navigate to: `http://localhost:5678`

## Configuration

### Environment Variables

The following environment variables should be configured in your `.env` file:

**n8n Configuration:**
- `DOMAIN_NAME`: Your domain name (e.g., example.com)
- `SUBDOMAIN`: Subdomain for n8n (e.g., n8n)
- `GENERIC_TIMEZONE`: Timezone for n8n (default: America/Lima)
- `TZ`: System timezone (default: America/Lima)
- `SSL_EMAIL`: Email address for Let's Encrypt certificates

**LangSmith Integration:**
- `LANGSMITH_API_KEY`: Required for LangSmith tracing integration
- `LANGSMITH_PROJECT`: Project name for LangSmith (default: "n8n")
- `LANGSMITH_ENDPOINT`: LangSmith API endpoint
- `LANGSMITH_TRACING_V2`: Enable LangSmith v2 tracing

### Database Options

**SQLite (Default)**
- Lightweight and perfect for development and small deployments
- Data stored in Docker volume
- No additional setup required

**PostgreSQL (Optional)**
- Better for production deployments with high volume
- Uncomment the database service in `docker-compose.yml`
- Configure PostgreSQL environment variables

### Port Configuration

**Local Development:**
- n8n web interface: `localhost:5678`
- Traefik dashboard: `localhost:8080` (if enabled)

**Production (with domain):**
- n8n web interface: `https://${SUBDOMAIN}.${DOMAIN_NAME}`
- Automatic HTTP to HTTPS redirect
- SSL/TLS certificates via Let's Encrypt

**Default Settings:**
- Default timezone: `America/Lima`

## Common Commands

### Quick Setup

```bash
# Initialize and start everything (recommended for new setups)
./scripts/init.sh

# Create external volumes manually (if needed)
docker volume create n8n_data
docker volume create traefik_data
```

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

# Build and pull latest n8n image
docker-compose build --pull
docker-compose pull
```

### Maintenance

```bash
# View container status
docker-compose ps

# Access n8n container shell
docker-compose exec n8n sh

# Backup data volumes
docker run --rm -v n8n_data:/data -v $(pwd):/backup alpine tar czf /backup/n8n-backup.tar.gz -C /data .
docker run --rm -v traefik_data:/data -v $(pwd):/backup alpine tar czf /backup/traefik-backup.tar.gz -C /data .

# View SSL certificates
docker-compose exec traefik ls -la /letsencrypt/
```

## Data Persistence

- All n8n data (workflows, credentials, settings) persists in the Docker volume `n8n_data`
- SSL certificates and Traefik configuration persist in the Docker volume `traefik_data`
- Local files accessible via `/files` directory in n8n workflows (mounted from `./local-files`)
- Database location: `/home/node/.n8n/database.sqlite` (SQLite) or PostgreSQL container
- Data survives container restarts and updates

## Architecture

```
                    ┌─────────────────────┐
                    │   Traefik Proxy     │
                    │   Ports: 80/443     │
                    │   SSL Termination   │
                    └─────────┬───────────┘
                              │
                    ┌─────────▼───────────┐
                    │   n8n Container     │
                    │   Port: 5678        │
                    └─────────┬───────────┘
                              │
          ┌───────────────────┼───────────────────┐
          │                   │                   │
  ┌───────▼────────┐  ┌───────▼────────┐  ┌──────▼──────┐
  │ Docker Volume  │  │ Docker Volume  │  │ Local Files │
  │ (n8n_data)     │  │ (traefik_data) │  │ (./local)   │
  │ Workflows &    │  │ SSL Certs &    │  │ File Access │
  │ Settings       │  │ Config         │  │ for n8n     │
  └────────────────┘  └────────────────┘  └─────────────┘
                              │
                    ┌─────────▼───────────┐
                    │ LangSmith           │
                    │ Integration         │
                    │ Tracing & Monitor   │
                    └─────────────────────┘
```

## Upgrading

To upgrade n8n to the latest version:

1. **Update the version in Dockerfile.n8n** (currently using n8n:1.105.2)
2. **Rebuild and restart:**
   ```bash
   docker-compose build --pull
   docker-compose up -d
   ```

3. **Verify the upgrade:**
   ```bash
   docker-compose logs -f n8n
   ```

## Troubleshooting

### Common Issues

1. **Port already in use**: Change the port mapping in `docker-compose.yml`
2. **Permission issues**: Ensure Docker has proper permissions
3. **LangSmith connection**: Verify your API key in the `.env` file
4. **SSL certificate issues**: Check Traefik logs and ensure email is configured
5. **Domain not resolving**: Verify DNS settings point to your server
6. **Local files not accessible**: Ensure `./local-files` directory exists and has proper permissions

### Logs and Debugging

```bash
# View detailed logs
docker-compose logs -f n8n
docker-compose logs -f traefik

# Check container health
docker-compose ps

# Test SSL certificate
curl -I https://${SUBDOMAIN}.${DOMAIN_NAME}

# Check Traefik dashboard (if enabled)
open http://localhost:8080
```

## Security Considerations

- **SSL/TLS**: Automatic HTTPS with Let's Encrypt certificates
- **Headers**: Security headers configured via Traefik middleware
- **Database**: Use strong passwords for database connections
- **Environment**: Keep your `.env` file secure and never commit it to version control
- **Updates**: Regularly update both n8n and Traefik images for security patches
- **Firewall**: Only expose ports 80 and 443 to the internet
- **Domain**: Use a proper domain name for production deployments

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test the deployment
5. Submit a pull request

## License

This project configuration is provided as-is. Please refer to n8n's official licensing for the n8n software itself.

## Support

- [n8n Documentation](https://docs.n8n.io/)
- [n8n Community Forum](https://community.n8n.io/)
- [LangSmith Documentation](https://docs.langsmith.com/)

---

**Note**: This is a self-hosted deployment. For production use, consider additional security measures, backup strategies, and monitoring solutions.
