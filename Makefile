.PHONY: help setup start stop restart logs build install-nodes clean env-setup volumes

# Colors for output
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[1;33m
BLUE := \033[0;34m
NC := \033[0m

# Helper functions
define print_status
	@echo -e "$(GREEN)✓$(NC) $(1)"
endef

define print_warning
	@echo -e "$(YELLOW)⚠$(NC) $(1)"
endef

define print_error
	@echo -e "$(RED)✗$(NC) $(1)"
endef

define print_info
	@echo -e "$(BLUE)ℹ$(NC) $(1)"
endef

help: ## Show this help message
	@echo "🚀 self-n8n Management Commands"
	@echo ""
	@echo "Usage: make [target]"
	@echo ""
	@echo "Available targets:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(BLUE)%-15s$(NC) %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo ""
	@echo "Examples:"
	@echo "  make setup          # Complete setup and start services"
	@echo "  make start          # Start existing services"
	@echo "  make install-nodes  # Install community nodes"
	@echo "  make logs           # View n8n logs"
	@echo ""
	@echo "Environment:"
	@echo "  • Edit .env file for configuration"
	@echo "  • Required for production: DOMAIN_NAME, SUBDOMAIN, SSL_EMAIL"
	@echo "  • Optional: LANGSMITH_API_KEY for LangSmith integration"

setup: env-setup volumes build start ## Complete setup: env file, volumes, build, and start
	@echo ""
	$(call print_status,"Setup complete! 🎉")
	@echo ""
	@if grep -q "^DOMAIN_NAME=.\\+" .env 2>/dev/null && grep -q "^SUBDOMAIN=.\\+" .env 2>/dev/null; then \
		DOMAIN=$$(grep "^DOMAIN_NAME=" .env | cut -d'=' -f2); \
		SUBDOMAIN=$$(grep "^SUBDOMAIN=" .env | cut -d'=' -f2); \
		$(call print_info,"n8n will be available at: $(BLUE)https://$$SUBDOMAIN.$$DOMAIN$(NC) (after DNS setup)"); \
		$(call print_info,"Local access: $(BLUE)http://localhost:5678$(NC)"); \
		$(call print_warning,"Make sure your DNS points to this server for SSL to work"); \
	else \
		$(call print_info,"n8n is now available at: $(BLUE)http://localhost:5678$(NC)"); \
		$(call print_warning,"For production use, configure DOMAIN_NAME, SUBDOMAIN, and SSL_EMAIL in .env"); \
	fi
	@echo ""
	$(call print_info,"Next steps:")
	@echo "  • make install-nodes  # Install community nodes"
	@echo "  • make logs           # View service logs"

env-setup: ## Create .env file from example
	@if [ ! -f ".env" ]; then \
		if [ -f ".env.example" ]; then \
			cp .env.example .env; \
			$(call print_status,"Created .env file from .env.example"); \
			$(call print_warning,"Please edit .env file with your configuration"); \
		else \
			$(call print_warning,"No .env.example found. Creating basic .env file"); \
			echo "# n8n Configuration" > .env; \
			echo "DOMAIN_NAME=" >> .env; \
			echo "SUBDOMAIN=" >> .env; \
			echo "GENERIC_TIMEZONE=America/Lima" >> .env; \
			echo "TZ=America/Lima" >> .env; \
			echo "SSL_EMAIL=" >> .env; \
			echo "" >> .env; \
			echo "# LangSmith Integration (Optional)" >> .env; \
			echo "LANGSMITH_ENDPOINT=https://api.smith.langchain.com" >> .env; \
			echo "LANGSMITH_TRACING_V2=true" >> .env; \
			echo "LANGSMITH_API_KEY=" >> .env; \
			echo "LANGSMITH_PROJECT=n8n" >> .env; \
			$(call print_status,"Created basic .env file"); \
		fi; \
	else \
		$(call print_status,".env file already exists"); \
	fi

volumes: ## Create required Docker volumes
	@$(call print_info,"Checking Docker volumes...")
	@for volume in n8n_data traefik_data; do \
		if docker volume inspect $$volume > /dev/null 2>&1; then \
			$(call print_status,"Docker volume '$$volume' already exists"); \
		else \
			$(call print_info,"Creating Docker volume '$$volume'..."); \
			docker volume create $$volume; \
			$(call print_status,"Created Docker volume '$$volume'"); \
		fi; \
	done
	@if [ ! -d "local-files" ]; then \
		mkdir -p local-files; \
		$(call print_status,"Created local-files directory for n8n workflows"); \
	else \
		$(call print_status,"local-files directory already exists"); \
	fi

build: ## Build custom n8n image
	@if ! docker info > /dev/null 2>&1; then \
		$(call print_error,"Docker is not running. Please start Docker and try again."); \
		exit 1; \
	fi
	@if ! command -v docker-compose > /dev/null 2>&1; then \
		$(call print_error,"docker-compose is not installed. Please install docker-compose and try again."); \
		exit 1; \
	fi
	$(call print_info,"Building custom n8n image with xmldom support...")
	@docker-compose build --pull

start: ## Start all services (n8n + Traefik)
	$(call print_info,"Starting all services (n8n + Traefik)...")
	@docker-compose up -d
	@sleep 3
	@if docker-compose ps | grep -q "Up"; then \
		$(call print_status,"Services started successfully!"); \
	else \
		$(call print_error,"Failed to start services. Check logs with: make logs"); \
		exit 1; \
	fi

stop: ## Stop all services
	$(call print_info,"Stopping all services...")
	@docker-compose down
	$(call print_status,"Services stopped")

restart: ## Restart all services
	$(call print_info,"Restarting all services...")
	@docker-compose restart
	$(call print_status,"Services restarted")

logs: ## View n8n service logs
	@docker-compose logs -f n8n

logs-traefik: ## View Traefik service logs
	@docker-compose logs -f traefik

logs-all: ## View all service logs
	@docker-compose logs -f

install-nodes: ## Install community nodes (n8n-nodes-mcp)
	@if ! docker-compose ps n8n | grep -q "Up"; then \
		$(call print_error,"n8n service is not running. Please run 'make start' first."); \
		exit 1; \
	fi
	$(call print_info,"Installing community nodes...")
	@chmod +x scripts/install-community-nodes.sh
	@./scripts/install-community-nodes.sh

status: ## Show status of all services
	@docker-compose ps

clean: ## Stop services and remove volumes (WARNING: This deletes all data!)
	@echo -e "$(RED)WARNING: This will delete all n8n data and SSL certificates!$(NC)"
	@read -p "Are you sure? Type 'yes' to continue: " confirm && [ "$$confirm" = "yes" ] || exit 1
	@docker-compose down -v
	@docker volume rm n8n_data traefik_data 2>/dev/null || true
	@rm -rf local-files
	$(call print_status,"Cleanup complete")

# Development helpers
shell-n8n: ## Open shell in n8n container
	@docker-compose exec n8n /bin/bash

shell-traefik: ## Open shell in Traefik container  
	@docker-compose exec traefik /bin/sh

# SSL and domain helpers
check-ssl: ## Check SSL certificate status
	@docker-compose exec traefik ls -la /letsencrypt/ || $(call print_error,"Traefik container not running")

test-https: ## Test HTTPS connection (requires DOMAIN_NAME and SUBDOMAIN in .env)
	@if [ -f ".env" ]; then \
		DOMAIN=$$(grep "^DOMAIN_NAME=" .env | cut -d'=' -f2); \
		SUBDOMAIN=$$(grep "^SUBDOMAIN=" .env | cut -d'=' -f2); \
		if [ -n "$$DOMAIN" ] && [ -n "$$SUBDOMAIN" ]; then \
			$(call print_info,"Testing HTTPS connection to https://$$SUBDOMAIN.$$DOMAIN"); \
			curl -I "https://$$SUBDOMAIN.$$DOMAIN" || $(call print_error,"HTTPS test failed"); \
		else \
			$(call print_error,"DOMAIN_NAME and SUBDOMAIN must be set in .env file"); \
		fi; \
	else \
		$(call print_error,".env file not found"); \
	fi