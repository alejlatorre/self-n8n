#!/bin/bash

# Install community nodes script for n8n
# This script installs the n8n-nodes-mcp community node package

set -e  # Exit on any error

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

echo "🔌 Installing n8n community nodes..."

# Check if n8n container is running
if ! docker-compose ps n8n | grep -q "Up"; then
    print_error "n8n container is not running. Please start it first with: make start"
    exit 1
fi

print_status "n8n container is running"

# Install the community node package
print_info "Installing n8n-nodes-mcp package..."
if docker-compose exec -T n8n npm install n8n-nodes-mcp; then
    print_status "Successfully installed n8n-nodes-mcp"
else
    print_error "Failed to install n8n-nodes-mcp"
    exit 1
fi

# Restart n8n to load the new nodes
print_info "Restarting n8n to load the new community nodes..."
if docker-compose restart n8n; then
    print_status "n8n restarted successfully"
else
    print_error "Failed to restart n8n"
    exit 1
fi

# Wait for n8n to be ready
print_info "Waiting for n8n to be ready..."
sleep 10

# Check if n8n is responsive
if docker-compose ps n8n | grep -q "Up"; then
    print_status "n8n is running and ready!"
    echo ""
    print_info "Community nodes installed successfully! 🎉"
    print_info "You can now use the MCP nodes in your n8n workflows."
    print_info "Access n8n at: http://localhost:5678"
    echo ""
    print_info "To check installed packages, run:"
    echo "  docker-compose exec n8n npm list n8n-nodes-mcp"
else
    print_error "n8n failed to start after installing community nodes"
    print_info "Check logs with: make logs"
    exit 1
fi