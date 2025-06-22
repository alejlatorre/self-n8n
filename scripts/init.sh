#!/bin/bash

# self-n8n initialization script
# This script sets up the n8n environment and starts the services

set -e  # Exit on any error

echo "🚀 Initializing self-n8n setup..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    print_error "Docker is not running. Please start Docker and try again."
    exit 1
fi

print_status "Docker is running"

# Check if docker-compose is available
if ! command -v docker-compose &> /dev/null; then
    print_error "docker-compose is not installed. Please install docker-compose and try again."
    exit 1
fi

print_status "docker-compose is available"

# Create .env file if it doesn't exist
if [ ! -f ".env" ]; then
    if [ -f ".env.example" ]; then
        cp .env.example .env
        print_status "Created .env file from .env.example"
        print_warning "Please edit .env file with your configuration before continuing"
        print_info "Especially set your LANGSMITH_API_KEY if you want LangSmith integration"
    else
        print_warning "No .env.example found. Creating a basic .env file"
        cat > .env << EOL
# Basic n8n configuration
# Add your LangSmith API key here for tracing integration
# LANGSMITH_API_KEY=your_api_key_here
# LANGSMITH_PROJECT=n8n
EOL
        print_status "Created basic .env file"
    fi
else
    print_status ".env file already exists"
fi

# Check if the external volume exists
VOLUME_NAME="n8n_data"
if docker volume inspect $VOLUME_NAME > /dev/null 2>&1; then
    print_status "Docker volume '$VOLUME_NAME' already exists"
else
    print_info "Creating Docker volume '$VOLUME_NAME'..."
    docker volume create $VOLUME_NAME
    print_status "Created Docker volume '$VOLUME_NAME'"
fi

# Build and start the services
print_info "Building custom n8n image with xmldom support..."
docker-compose build --pull

print_info "Starting n8n services..."
docker-compose up -d

# Wait a moment for services to start
sleep 3

# Check if services are running
if docker-compose ps | grep -q "Up"; then
    print_status "Services started successfully!"
    echo ""
    print_info "n8n is now available at: ${BLUE}http://localhost:5678${NC}"
    echo ""
    print_info "Useful commands:"
    echo "  • Check status: docker-compose ps"
    echo "  • View logs: docker-compose logs -f n8n"
    echo "  • Stop services: docker-compose down"
    echo "  • Restart services: docker-compose restart"
    echo ""
    print_info "To access n8n logs in real-time:"
    echo "  docker-compose logs -f n8n"
else
    print_error "Failed to start services. Check the logs with: docker-compose logs"
    exit 1
fi

echo ""
print_status "Setup complete! 🎉" 