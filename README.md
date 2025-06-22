# self-n8n

A self-hosted n8n workflow automation platform deployment using Docker Compose, configured with LangSmith integration for advanced workflow tracing and monitoring.

## Overview

This project provides a containerized deployment of n8n, a powerful workflow automation tool that allows you to create complex automation workflows through an intuitive visual interface. The setup includes optional LangSmith integration for workflow tracing and monitoring capabilities.

## Features

- 🐳 **Containerized Deployment**: Easy setup using Docker Compose
- 🗄️ **Flexible Database Options**: Supports both SQLite (default) and PostgreSQL
- 📊 **LangSmith Integration**: Advanced workflow tracing and monitoring via LangChain
- 🔄 **Data Persistence**: Workflows and data persist between container restarts
- ⚙️ **Environment-based Configuration**: Easy configuration through environment variables

## Prerequisites

- Docker and Docker Compose installed on your system
- Basic understanding of n8n workflow automation

## Quick Start

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd self-n8n
   ```

2. **Set up environment variables**
   ```bash
   # Create your environment file
   cp .env.example .env
   
   # Edit the .env file with your configuration
   # Required: LANGSMITH_API_KEY for LangSmith integration
   ```

3. **Start the services**
   ```bash
   docker-compose up -d
   ```

4. **Access n8n**
   Open your browser and navigate to: `http://localhost:5678`

## Configuration

### Environment Variables

The following environment variables should be configured in your `.env` file:

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

- n8n web interface: `localhost:5678`
- Default timezone: `America/Lima`

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

### Maintenance

```bash
# View container status
docker-compose ps

# Access n8n container shell
docker-compose exec n8n sh

# Backup data volume
docker run --rm -v self-n8n_data:/data -v $(pwd):/backup alpine tar czf /backup/n8n-backup.tar.gz -C /data .
```

## Data Persistence

- All n8n data (workflows, credentials, settings) persists in the Docker volume `data`
- Database location: `/home/node/.n8n/database.sqlite` (SQLite) or PostgreSQL container
- Data survives container restarts and updates

## Architecture

```
┌─────────────────────┐
│   n8n Container     │
│   Port: 5678        │
└─────────┬───────────┘
          │
          ├─ Docker Volume (data)
          │  └─ Workflows & Settings
          │
          └─ LangSmith Integration
             └─ Tracing & Monitoring
```

## Upgrading

To upgrade n8n to the latest version:

```bash
docker-compose pull
docker-compose up -d
```

## Troubleshooting

### Common Issues

1. **Port already in use**: Change the port mapping in `docker-compose.yml`
2. **Permission issues**: Ensure Docker has proper permissions
3. **LangSmith connection**: Verify your API key in the `.env` file

### Logs and Debugging

```bash
# View detailed logs
docker-compose logs -f n8n

# Check container health
docker-compose ps
```

## Security Considerations

- Change default ports if exposing to the internet
- Use strong passwords for database connections
- Keep your `.env` file secure and never commit it to version control
- Regularly update the n8n image for security patches

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
