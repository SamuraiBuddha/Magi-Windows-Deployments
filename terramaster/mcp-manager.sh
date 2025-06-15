#!/bin/bash
# MCP Stack Management Script for Terramaster
# Provides easy management commands for the comprehensive MCP deployment

set -e

# Configuration
MCP_DIR="/Volume1/docker/mcp-stack"
COMPOSE_FILE="$MCP_DIR/docker-compose.yml"
ENV_FILE="$MCP_DIR/.env"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Check if running in correct directory
check_directory() {
    if [ ! -f "$COMPOSE_FILE" ]; then
        echo -e "${RED}Error: docker-compose.yml not found!${NC}"
        echo "Please run this script from $MCP_DIR"
        exit 1
    fi
}

# Show usage
usage() {
    echo -e "${BLUE}MCP Stack Manager${NC}"
    echo "=================="
    echo ""
    echo "Usage: $0 [command] [options]"
    echo ""
    echo "Commands:"
    echo "  status      - Show status of all services"
    echo "  start       - Start all services"
    echo "  stop        - Stop all services"
    echo "  restart     - Restart all services"
    echo "  essential   - Start only essential services"
    echo "  logs        - Show logs (optional: service name)"
    echo "  update      - Update all container images"
    echo "  backup      - Backup data directories"
    echo "  health      - Health check all services"
    echo "  config      - Validate configuration"
    echo "  clean       - Clean unused images and volumes"
    echo ""
    echo "Examples:"
    echo "  $0 status"
    echo "  $0 logs mcp-postgres"
    echo "  $0 essential"
}

# Show status
show_status() {
    echo -e "${BLUE}MCP Services Status${NC}"
    echo "==================="
    cd "$MCP_DIR"
    docker-compose ps --format "table {{.Service}}\t{{.Status}}\t{{.Ports}}"
    
    echo -e "\n${BLUE}Resource Usage${NC}"
    echo "=============="
    docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}" \
        $(docker-compose ps -q 2>/dev/null) 2>/dev/null || echo "No containers running"
}

# Start services
start_services() {
    echo -e "${GREEN}Starting MCP services...${NC}"
    cd "$MCP_DIR"
    
    if [ "$1" == "essential" ]; then
        echo "Starting essential services only..."
        docker-compose up -d \
            mcp-redis \
            mcp-postgres \
            mcp-filesystem \
            mcp-basic-memory \
            mcp-github
    else
        docker-compose up -d
    fi
    
    echo -e "${GREEN}Services started!${NC}"
    sleep 5
    show_status
}

# Stop services
stop_services() {
    echo -e "${YELLOW}Stopping MCP services...${NC}"
    cd "$MCP_DIR"
    docker-compose down
    echo -e "${GREEN}Services stopped!${NC}"
}

# Restart services
restart_services() {
    echo -e "${YELLOW}Restarting MCP services...${NC}"
    stop_services
    sleep 2
    start_services
}

# Show logs
show_logs() {
    cd "$MCP_DIR"
    if [ -z "$1" ]; then
        docker-compose logs --tail=100 -f
    else
        docker-compose logs --tail=100 -f "$1"
    fi
}

# Update images
update_images() {
    echo -e "${BLUE}Updating MCP container images...${NC}"
    cd "$MCP_DIR"
    docker-compose pull
    echo -e "${GREEN}Images updated!${NC}"
    echo ""
    echo -e "${YELLOW}Restart services to use new images:${NC}"
    echo "  $0 restart"
}

# Backup data
backup_data() {
    BACKUP_DIR="/Volume1/backups/mcp"
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    BACKUP_PATH="$BACKUP_DIR/mcp_backup_$TIMESTAMP"
    
    echo -e "${BLUE}Creating backup...${NC}"
    mkdir -p "$BACKUP_PATH"
    
    # Stop services for consistent backup
    echo "Stopping services for backup..."
    cd "$MCP_DIR"
    docker-compose stop
    
    # Backup data directories
    echo "Backing up data directories..."
    tar -czf "$BACKUP_PATH/data.tar.gz" -C "$MCP_DIR" data/
    
    # Backup configuration
    echo "Backing up configuration..."
    cp "$COMPOSE_FILE" "$BACKUP_PATH/"
    cp "$ENV_FILE" "$BACKUP_PATH/" 2>/dev/null || true
    
    # Restart services
    echo "Restarting services..."
    docker-compose start
    
    # Calculate backup size
    BACKUP_SIZE=$(du -sh "$BACKUP_PATH" | cut -f1)
    echo -e "${GREEN}Backup complete!${NC}"
    echo "Location: $BACKUP_PATH"
    echo "Size: $BACKUP_SIZE"
}

# Health check
health_check() {
    echo -e "${BLUE}MCP Services Health Check${NC}"
    echo "========================="
    
    # Check core services
    echo -e "\n${YELLOW}Core Services:${NC}"
    
    # PostgreSQL
    echo -n "PostgreSQL (5432): "
    if nc -z localhost 5432 2>/dev/null; then
        echo -e "${GREEN}✓ Healthy${NC}"
    else
        echo -e "${RED}✗ Not responding${NC}"
    fi
    
    # Redis
    echo -n "Redis (6379): "
    if nc -z localhost 6379 2>/dev/null; then
        echo -e "${GREEN}✓ Healthy${NC}"
    else
        echo -e "${RED}✗ Not responding${NC}"
    fi
    
    # Neo4j
    echo -n "Neo4j (7474): "
    if nc -z localhost 7474 2>/dev/null; then
        echo -e "${GREEN}✓ Healthy${NC}"
    else
        echo -e "${RED}✗ Not responding${NC}"
    fi
    
    # Portainer
    echo -n "Portainer (9000): "
    if nc -z localhost 9000 2>/dev/null; then
        echo -e "${GREEN}✓ Healthy${NC}"
    else
        echo -e "${RED}✗ Not responding${NC}"
    fi
    
    # Docker health checks
    echo -e "\n${YELLOW}Container Health:${NC}"
    cd "$MCP_DIR"
    docker-compose ps --format "table {{.Service}}\t{{.State}}" | grep -E "(running|healthy)" || true
    
    # Disk usage
    echo -e "\n${YELLOW}Disk Usage:${NC}"
    df -h | grep -E "(Filesystem|Volume1)" || true
    
    # Data directory sizes
    echo -e "\n${YELLOW}Data Directory Sizes:${NC}"
    du -sh "$MCP_DIR/data/"* 2>/dev/null | sort -h || echo "No data directories found"
}

# Validate configuration
validate_config() {
    echo -e "${BLUE}Validating Configuration${NC}"
    echo "========================"
    
    # Check docker-compose syntax
    echo -n "Docker Compose syntax: "
    cd "$MCP_DIR"
    if docker-compose config >/dev/null 2>&1; then
        echo -e "${GREEN}✓ Valid${NC}"
    else
        echo -e "${RED}✗ Invalid${NC}"
        docker-compose config
        exit 1
    fi
    
    # Check .env file
    echo -n "Environment file: "
    if [ -f "$ENV_FILE" ]; then
        echo -e "${GREEN}✓ Found${NC}"
        
        # Check for required passwords
        echo -e "\n${YELLOW}Checking required passwords:${NC}"
        for var in POSTGRES_PASSWORD REDIS_PASSWORD NEO4J_PASSWORD; do
            if grep -q "^$var=.*changeme" "$ENV_FILE"; then
                echo -e "  $var: ${RED}✗ Still using default!${NC}"
            else
                echo -e "  $var: ${GREEN}✓ Set${NC}"
            fi
        done
    else
        echo -e "${RED}✗ Not found${NC}"
        echo "Please create .env from .env.template"
    fi
    
    # Check network
    echo -e "\n${YELLOW}Docker networks:${NC}"
    docker network ls | grep mcp_network || echo "Network not created yet"
}

# Clean unused resources
clean_resources() {
    echo -e "${YELLOW}Cleaning unused Docker resources...${NC}"
    
    # Remove stopped containers
    echo "Removing stopped containers..."
    docker container prune -f
    
    # Remove unused images
    echo "Removing unused images..."
    docker image prune -a -f
    
    # Remove unused volumes
    echo "Removing unused volumes..."
    docker volume prune -f
    
    # Show disk usage
    echo -e "\n${GREEN}Cleanup complete!${NC}"
    echo "Disk usage:"
    df -h | grep -E "(Filesystem|Volume1)"
}

# Main script logic
check_directory

case "$1" in
    status)
        show_status
        ;;
    start)
        start_services
        ;;
    essential)
        start_services "essential"
        ;;
    stop)
        stop_services
        ;;
    restart)
        restart_services
        ;;
    logs)
        show_logs "$2"
        ;;
    update)
        update_images
        ;;
    backup)
        backup_data
        ;;
    health)
        health_check
        ;;
    config)
        validate_config
        ;;
    clean)
        clean_resources
        ;;
    *)
        usage
        exit 1
        ;;
esac