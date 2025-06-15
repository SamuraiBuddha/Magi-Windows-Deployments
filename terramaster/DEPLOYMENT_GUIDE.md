# 🚀 Deploying the Complete MCP Stack on Terramaster

This guide helps you deploy all 28 MCP services on your Terramaster F8 Plus NAS.

## Prerequisites

- Terramaster F8 Plus with TOS 6.0
- Docker and Docker Compose installed
- At least 32GB free space on NVMe
- All Magi workstations on same network subnet

## Step 1: Prepare the Terramaster

SSH into your Terramaster:
```bash
ssh admin@terramaster.local
```

Create the MCP directory structure:
```bash
# Create base directory
sudo mkdir -p /Volume1/docker/mcp-stack
cd /Volume1/docker/mcp-stack

# Create data directories
mkdir -p data/{redis,postgres,neo4j,shared,papers,sandbox}
mkdir -p data/{basic-memory,context7,atlas-docs,youtube-cache}
mkdir -p data/{playwright,osp-marketing,desktop-commander}
mkdir -p init-scripts logs

# Set permissions
sudo chown -R $(whoami):docker data/
chmod -R 755 data/
```

## Step 2: Download Configuration Files

```bash
# Download the docker-compose file
wget https://raw.githubusercontent.com/SamuraiBuddha/Magi-Windows-Deployments/main/terramaster/docker-compose-full.yml -O docker-compose.yml

# Download the environment template
wget https://raw.githubusercontent.com/SamuraiBuddha/Magi-Windows-Deployments/main/terramaster/.env.template -O .env

# Edit the .env file with your values
nano .env
```

## Step 3: Configure API Keys

Edit the `.env` file and add your API keys:

### Essential Services (configure these first):
- `POSTGRES_PASSWORD` - Strong password for database
- `REDIS_PASSWORD` - Strong password for Redis
- `NEO4J_PASSWORD` - Strong password for Neo4j
- `GITHUB_TOKEN` - GitHub Personal Access Token

### Optional Services (add as needed):
- `NOTION_TOKEN` - For Notion integration
- `YOUTUBE_API_KEY` - For YouTube transcripts
- `PERPLEXITY_API_KEY` - For Perplexity searches
- `PINECONE_API_KEY` - For vector database
- `AZURE_*` - For Azure services

## Step 4: Start Core Services First

Start essential services:
```bash
# Start core infrastructure
docker-compose up -d mcp-redis mcp-postgres mcp-filesystem

# Wait for them to be healthy
docker-compose ps

# Then start memory services
docker-compose up -d mcp-neo4j-memory mcp-basic-memory

# Start development tools
docker-compose up -d mcp-desktop-commander mcp-github mcp-docker
```

## Step 5: Verify Services

Check all services are running:
```bash
# Check status
docker-compose ps

# Check logs for errors
docker-compose logs --tail=50

# Test connectivity
nc -zv localhost 5432  # PostgreSQL
nc -zv localhost 6379  # Redis
nc -zv localhost 7474  # Neo4j
```

## Step 6: Configure Windows Clients

On each Windows machine (Melchior, Balthazar, Caspar):

1. **Test connectivity**:
   ```powershell
   # Run from the Magi-Windows-Deployments repo
   .\scripts\Test-MCPConnectivity.ps1 -TerramasterHost "terramaster.local"
   ```

2. **Configure Claude Desktop**:
   
   Edit `%APPDATA%\Claude\claude_desktop_config.json`:
   ```json
   {
     "mcpServers": {
       "postgres": {
         "command": "npx",
         "args": [
           "-y",
           "@modelcontextprotocol/server-postgres",
           "postgresql://mcp:YOUR_PASSWORD@terramaster.local:5432/mcp_db"
         ]
       },
       "filesystem": {
         "command": "npx",
         "args": [
           "-y",
           "@modelcontextprotocol/server-filesystem",
           "\\\\terramaster.local\\docker\\mcp-stack\\data\\shared"
         ]
       },
       "github": {
         "command": "npx",
         "args": ["-y", "@modelcontextprotocol/server-github"],
         "env": {
           "GITHUB_TOKEN": "YOUR_GITHUB_TOKEN"
         }
       }
     }
   }
   ```

## Step 7: Start Remaining Services

Once core services are verified:
```bash
# Start all remaining services
docker-compose up -d

# Monitor startup
docker-compose logs -f
```

## Service Groups & Ports

### Core Infrastructure
- **PostgreSQL**: 5432
- **Redis**: 6379
- **Filesystem**: Internal only
- **Portainer**: 9000 (Web UI)

### AI/Memory Services
- **Neo4j**: 7474 (HTTP), 7687 (Bolt)
- **Basic Memory**: Internal only
- **Sequential Thinking**: Internal only

### Development Tools
- **GitHub**: Internal only
- **Docker**: Internal only
- **Desktop Commander**: Internal only
- **Node Sandbox**: Internal only

## Monitoring & Maintenance

### View logs:
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f mcp-postgres
```

### Update services:
```bash
# Pull latest images
docker-compose pull

# Restart with new images
docker-compose up -d
```

### Backup data:
```bash
# Stop services
docker-compose stop

# Backup data directory
tar -czf mcp-backup-$(date +%Y%m%d).tar.gz data/

# Restart services
docker-compose start
```

## Troubleshooting

### Service won't start
1. Check logs: `docker-compose logs service-name`
2. Verify API keys in `.env`
3. Check port conflicts: `netstat -tulpn | grep PORT`

### Can't connect from Windows
1. Check firewall on Terramaster
2. Verify services bound to `0.0.0.0` not `127.0.0.1`
3. Test with telnet: `telnet terramaster.local PORT`

### High memory usage
1. Check container stats: `docker stats`
2. Adjust memory limits in docker-compose.yml
3. Remove unused services

## Performance Tuning

For your 10GbE network:
```bash
# Enable jumbo frames (if supported)
sudo ip link set dev eth0 mtu 9000

# Optimize Docker
cat >> /etc/docker/daemon.json << EOF
{
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
EOF

sudo systemctl restart docker
```

## Next Steps

1. ✅ Test each MCP tool in Claude Desktop
2. ✅ Configure additional API keys as needed
3. ✅ Set up regular backups
4. ✅ Monitor resource usage
5. ✅ Document your custom configurations

Your centralized MCP stack is now ready! All Claude instances across your Magi workstations will share the same knowledge graph and state.