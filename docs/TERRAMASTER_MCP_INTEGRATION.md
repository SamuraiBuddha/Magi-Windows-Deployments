# 🗄️ Terramaster NAS Integration for Centralized MCP Services

## Overview

This guide configures your Terramaster F8 Plus (16TB NVMe) running TOS 6.0 as the central MCP server host, providing consistent memory and tools across all Claude Desktop instances.

## Benefits of Centralized MCP

- **Unified Memory**: Single knowledge graph accessible from all machines
- **Consistent State**: Same conversation context across devices
- **Resource Efficiency**: One set of containers instead of four
- **Centralized Management**: Update MCPs in one place
- **High Performance**: NVMe storage for fast access

## TOS 6.0 Docker vs Docker Desktop

### TOS 6.0 Docker App
- **Pros**: 
  - Native integration with TOS
  - Lower overhead (no VM layer)
  - Direct hardware access
  - Web-based management
  - Built-in container station
- **Cons**:
  - Limited to Linux containers
  - No Docker Compose GUI
  - Requires SSH for advanced config

### Docker Desktop
- **Pros**:
  - Full GUI experience
  - Easy compose management
  - Windows/Linux container support
- **Cons**:
  - Higher resource usage
  - Requires virtualization

**Recommendation**: Use TOS 6.0 Docker for MCP services (perfect for this use case)

## Terramaster Configuration

### 1. Enable Docker on TOS 6.0

```bash
# SSH into Terramaster
ssh admin@terramaster.local

# Check Docker status
docker version

# If not installed, install via TOS App Center
# Go to App Center → Docker → Install
```

### 2. Configure Docker Network

```bash
# Create dedicated network for MCP services
docker network create --driver bridge \
  --subnet=172.30.0.0/16 \
  --gateway=172.30.0.1 \
  --opt com.docker.network.bridge.name=mcp0 \
  mcp_network
```

### 3. Storage Configuration

```bash
# Create MCP data directories on NVMe
mkdir -p /Volume1/docker/mcp/{data,configs,logs}
mkdir -p /Volume1/docker/mcp/services/{postgres,redis,neo4j,influxdb,memory}

# Set permissions
chmod -R 755 /Volume1/docker/mcp
```

## MCP Services Deployment

### Core MCP Stack (docker-compose.yml)

```yaml
services:
  # PostgreSQL for persistent storage
  mcp-postgres:
    image: postgres:16-alpine
    container_name: mcp-postgres
    restart: unless-stopped
    environment:
      POSTGRES_USER: mcp
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_DB: mcp_db
    volumes:
      - /Volume1/docker/mcp/services/postgres:/var/lib/postgresql/data
    ports:
      - "5432:5432"
    networks:
      - mcp_network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U mcp"]
      interval: 10s
      timeout: 5s
      retries: 5

  # Redis for caching and pub/sub
  mcp-redis:
    image: redis:7-alpine
    container_name: mcp-redis
    restart: unless-stopped
    command: redis-server --appendonly yes --requirepass ${REDIS_PASSWORD}
    volumes:
      - /Volume1/docker/mcp/services/redis:/data
    ports:
      - "6379:6379"
    networks:
      - mcp_network
    healthcheck:
      test: ["CMD", "redis-cli", "--raw", "incr", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5

  # Neo4j for knowledge graph
  mcp-neo4j:
    image: neo4j:5-community
    container_name: mcp-neo4j
    restart: unless-stopped
    environment:
      NEO4J_AUTH: neo4j/${NEO4J_PASSWORD}
      NEO4J_PLUGINS: '["graph-data-science", "apoc"]'
      NEO4J_dbms_memory_pagecache_size: 2G
      NEO4J_dbms_memory_heap_max__size: 2G
    volumes:
      - /Volume1/docker/mcp/services/neo4j/data:/data
      - /Volume1/docker/mcp/services/neo4j/logs:/logs
    ports:
      - "7474:7474"  # HTTP
      - "7687:7687"  # Bolt
    networks:
      - mcp_network

  # InfluxDB for metrics
  mcp-influxdb:
    image: influxdb:2
    container_name: mcp-influxdb
    restart: unless-stopped
    environment:
      DOCKER_INFLUXDB_INIT_MODE: setup
      DOCKER_INFLUXDB_INIT_USERNAME: admin
      DOCKER_INFLUXDB_INIT_PASSWORD: ${INFLUXDB_PASSWORD}
      DOCKER_INFLUXDB_INIT_ORG: mcp
      DOCKER_INFLUXDB_INIT_BUCKET: metrics
      DOCKER_INFLUXDB_INIT_RETENTION: 30d
    volumes:
      - /Volume1/docker/mcp/services/influxdb/data:/var/lib/influxdb2
      - /Volume1/docker/mcp/services/influxdb/config:/etc/influxdb2
    ports:
      - "8086:8086"
    networks:
      - mcp_network

  # MCP Server Manager
  mcp-manager:
    image: node:20-slim
    container_name: mcp-manager
    restart: unless-stopped
    working_dir: /app
    command: >
      sh -c "npm install -g @modelcontextprotocol/server-manager &&
             mcp-manager start --config /config/mcp-servers.json"
    volumes:
      - /Volume1/docker/mcp/configs:/config
      - /Volume1/docker/mcp/data:/data
    ports:
      - "3100:3100"  # Manager API
    networks:
      - mcp_network
    depends_on:
      - mcp-postgres
      - mcp-redis
      - mcp-neo4j

networks:
  mcp_network:
    external: true
```

### Environment Configuration (.env)

```bash
# Database Passwords
POSTGRES_PASSWORD=ChangeToSecurePassword
REDIS_PASSWORD=ChangeToSecurePassword
NEO4J_PASSWORD=ChangeToSecurePassword
INFLUXDB_PASSWORD=ChangeToSecurePassword

# MCP Configuration
MCP_HOST=terramaster.local
MCP_PORT=3100

# Resource Limits
MEMORY_LIMIT=16G
CPU_LIMIT=8
```

## MCP Server Configuration

### /Volume1/docker/mcp/configs/mcp-servers.json

```json
{
  "servers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/data/shared"],
      "env": {
        "MCP_ALLOWED_PATHS": "/data/shared"
      }
    },
    "postgres": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres", "postgresql://mcp:${POSTGRES_PASSWORD}@mcp-postgres:5432/mcp_db"],
      "env": {}
    },
    "redis": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-redis"],
      "env": {
        "REDIS_URL": "redis://:${REDIS_PASSWORD}@mcp-redis:6379"
      }
    },
    "neo4j": {
      "command": "npx",
      "args": ["-y", "mcp-neo4j"],
      "env": {
        "NEO4J_URI": "bolt://mcp-neo4j:7687",
        "NEO4J_USERNAME": "neo4j",
        "NEO4J_PASSWORD": "${NEO4J_PASSWORD}"
      }
    },
    "memory": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"],
      "env": {
        "STORAGE_PATH": "/data/memory"
      }
    },
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_TOKEN": "${GITHUB_TOKEN}"
      }
    }
  }
}
```

## Client Configuration (Claude Desktop)

### On Each Workstation

Edit Claude Desktop configuration to point to Terramaster:

**Windows**: `%APPDATA%\Claude\claude_desktop_config.json`
**macOS**: `~/Library/Application Support/Claude/claude_desktop_config.json`
**Linux**: `~/.config/Claude/claude_desktop_config.json`

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "ssh",
      "args": [
        "admin@terramaster.local",
        "docker exec mcp-manager npx -y @modelcontextprotocol/server-filesystem /data/shared"
      ]
    },
    "postgres": {
      "command": "ssh",
      "args": [
        "admin@terramaster.local",
        "docker exec mcp-manager npx -y @modelcontextprotocol/server-postgres postgresql://mcp:password@localhost:5432/mcp_db"
      ]
    },
    "memory": {
      "command": "ssh",
      "args": [
        "admin@terramaster.local",
        "docker exec mcp-manager npx -y @modelcontextprotocol/server-memory"
      ]
    },
    "neo4j": {
      "command": "ssh",
      "args": [
        "admin@terramaster.local",
        "docker exec mcp-manager npx -y mcp-neo4j"
      ],
      "env": {
        "NEO4J_URI": "bolt://terramaster.local:7687",
        "NEO4J_USERNAME": "neo4j",
        "NEO4J_PASSWORD": "your-password"
      }
    }
  }
}
```

### Alternative: MCP Proxy Configuration

For better performance, run a local MCP proxy on each machine:

```powershell
# Install MCP Proxy on each workstation
npm install -g @modelcontextprotocol/proxy

# Create proxy config
$proxyConfig = @{
    upstream = "http://terramaster.local:3100"
    cache = $true
    timeout = 30000
} | ConvertTo-Json

$proxyConfig | Set-Content "$env:APPDATA\Claude\mcp-proxy.json"

# Run proxy (add to startup)
mcp-proxy --config "$env:APPDATA\Claude\mcp-proxy.json" --port 3101
```

## Deployment Script

### deploy-mcp-terramaster.sh

```bash
#!/bin/bash
# Deploy MCP stack on Terramaster NAS

echo "🚀 Deploying MCP Stack on Terramaster NAS"

# Check if running on Terramaster
if [ ! -f /etc/terramaster-release ]; then
    echo "⚠️  This script should be run on Terramaster NAS"
    exit 1
fi

# Create directories
echo "📁 Creating directory structure..."
mkdir -p /Volume1/docker/mcp/{data,configs,logs}
mkdir -p /Volume1/docker/mcp/services/{postgres,redis,neo4j,influxdb,memory}
mkdir -p /Volume1/docker/mcp/data/{shared,memory}

# Copy configuration files
echo "📝 Copying configuration files..."
cp docker-compose.yml /Volume1/docker/mcp/
cp .env.example /Volume1/docker/mcp/.env
cp mcp-servers.json /Volume1/docker/mcp/configs/

# Set permissions
chmod -R 755 /Volume1/docker/mcp

# Create Docker network
echo "🌐 Creating MCP network..."
docker network create mcp_network 2>/dev/null || true

# Deploy stack
echo "🐳 Starting MCP services..."
cd /Volume1/docker/mcp
docker-compose up -d

# Wait for services
echo "⏳ Waiting for services to start..."
sleep 30

# Check health
echo "🏥 Checking service health..."
docker-compose ps

echo "✅ MCP Stack deployed successfully!"
echo ""
echo "Access points:"
echo "  PostgreSQL: terramaster.local:5432"
echo "  Redis: terramaster.local:6379"
echo "  Neo4j: http://terramaster.local:7474"
echo "  InfluxDB: http://terramaster.local:8086"
echo "  MCP Manager: http://terramaster.local:3100"
```

## Monitoring & Maintenance

### Health Check Script

```bash
#!/bin/bash
# Check MCP services health

echo "🔍 MCP Services Health Check"
echo "============================"

# Check containers
echo -e "\n📦 Container Status:"
docker ps --filter "name=mcp-" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Check disk usage
echo -e "\n💾 Disk Usage:"
du -sh /Volume1/docker/mcp/services/*

# Check network
echo -e "\n🌐 Network Connectivity:"
docker network inspect mcp_network | jq '.[0].Containers | keys[]'

# Check logs for errors
echo -e "\n📋 Recent Errors:"
docker-compose logs --tail=10 2>&1 | grep -i error || echo "No recent errors"
```

### Backup Script

```bash
#!/bin/bash
# Backup MCP data

BACKUP_DIR="/Volume1/backups/mcp/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "🔄 Backing up MCP data to $BACKUP_DIR"

# Stop services
docker-compose stop

# Backup data
tar -czf "$BACKUP_DIR/postgres.tar.gz" /Volume1/docker/mcp/services/postgres
tar -czf "$BACKUP_DIR/neo4j.tar.gz" /Volume1/docker/mcp/services/neo4j
tar -czf "$BACKUP_DIR/redis.tar.gz" /Volume1/docker/mcp/services/redis
tar -czf "$BACKUP_DIR/configs.tar.gz" /Volume1/docker/mcp/configs

# Restart services
docker-compose start

echo "✅ Backup complete!"
```

## Performance Optimization

### TOS 6.0 Optimizations

```bash
# Enable SSD caching for Docker
echo "vm.swappiness=10" >> /etc/sysctl.conf
echo "vm.vfs_cache_pressure=50" >> /etc/sysctl.conf

# Optimize network for 10GbE
echo "net.core.rmem_max=134217728" >> /etc/sysctl.conf
echo "net.core.wmem_max=134217728" >> /etc/sysctl.conf
echo "net.ipv4.tcp_rmem=4096 87380 134217728" >> /etc/sysctl.conf
echo "net.ipv4.tcp_wmem=4096 65536 134217728" >> /etc/sysctl.conf

# Apply settings
sysctl -p
```

## Troubleshooting

### Connection Issues from Claude Desktop

1. **Test SSH connectivity**:
   ```powershell
   ssh admin@terramaster.local "docker ps"
   ```

2. **Check firewall on Terramaster**:
   ```bash
   # Allow MCP ports
   ufw allow 5432/tcp  # PostgreSQL
   ufw allow 6379/tcp  # Redis
   ufw allow 7474/tcp  # Neo4j HTTP
   ufw allow 7687/tcp  # Neo4j Bolt
   ufw allow 8086/tcp  # InfluxDB
   ufw allow 3100/tcp  # MCP Manager
   ```

3. **Verify services are listening**:
   ```bash
   netstat -tlnp | grep -E '(5432|6379|7474|7687|8086|3100)'
   ```

### Performance Issues

1. **Check resource usage**:
   ```bash
   docker stats --no-stream
   ```

2. **Increase container resources**:
   ```yaml
   services:
     mcp-postgres:
       deploy:
         resources:
           limits:
             cpus: '2'
             memory: 4G
   ```

## Summary

With this setup:
- ✅ All Claude Desktop instances share the same memory/state
- ✅ Centralized management on your NVMe NAS
- ✅ High-performance storage for MCP data
- ✅ Easy backup and maintenance
- ✅ Resource efficient (one set of containers)

The Terramaster's Docker implementation is perfect for this use case, providing native performance without the overhead of Docker Desktop's VM layer.