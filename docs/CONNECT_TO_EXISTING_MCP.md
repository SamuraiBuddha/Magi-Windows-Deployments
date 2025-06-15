# 🔌 Quick Guide: Connect to Existing Terramaster MCP Services

Since you already have MCP services running in Docker Manager on your Terramaster, here's how to connect your Windows machines to them.

## Step 1: Check What's Running on Terramaster

SSH into your Terramaster and check MCP services:
```bash
# List all MCP containers
docker ps --filter "name=mcp" --format "table {{.Names}}\t{{.Image}}\t{{.Ports}}"

# Check network mode
docker inspect $(docker ps -q --filter "name=mcp") --format '{{.Name}}: {{.HostConfig.NetworkMode}}'
```

## Step 2: Test Connectivity from Windows

On each Windows machine, run:
```powershell
# Download and run the test script
.\scripts\Test-MCPConnectivity.ps1 -TerramasterHost "terramaster.local" -Verbose
```

## Step 3: Configure Claude Desktop

### Option A: Direct Connection (if services are accessible)

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
        "\\\\terramaster.local\\docker\\mcp\\shared"
      ]
    },
    "memory": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-memory"
      ],
      "env": {
        "STORAGE_BACKEND": "postgres",
        "POSTGRES_URL": "postgresql://mcp:YOUR_PASSWORD@terramaster.local:5432/mcp_db"
      }
    }
  }
}
```

### Option B: SSH Tunnel (if direct access is blocked)

1. First, setup SSH key:
```powershell
# Generate SSH key if needed
ssh-keygen -t rsa -b 4096 -f $env:USERPROFILE\.ssh\id_rsa_terramaster

# Copy to Terramaster (you'll need to enter password once)
type $env:USERPROFILE\.ssh\id_rsa_terramaster.pub | ssh admin@terramaster.local "cat >> ~/.ssh/authorized_keys"
```

2. Configure Claude with SSH tunnel:
```json
{
  "mcpServers": {
    "terramaster-tunnel": {
      "command": "ssh",
      "args": [
        "-L", "5432:localhost:5432",
        "-L", "6379:localhost:6379", 
        "-L", "7474:localhost:7474",
        "-L", "7687:localhost:7687",
        "-N",
        "admin@terramaster.local"
      ]
    },
    "postgres": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-postgres",
        "postgresql://mcp:YOUR_PASSWORD@localhost:5432/mcp_db"
      ],
      "dependsOn": ["terramaster-tunnel"]
    }
  }
}
```

## Network Mode Comparison

### If Using Host Mode
- Services bind directly to Terramaster's IP
- Access via: `terramaster.local:5432`
- No port mapping needed
- Simpler but less flexible

### If Using Bridge Mode (Recommended)
- Services in isolated network
- Explicit port mapping: `"5432:5432"`
- Access via: `terramaster.local:5432`
- More secure and manageable

## Quick Troubleshooting

### "Connection Refused" Errors
1. Check if binding to all interfaces:
   ```bash
   # On Terramaster, check docker-compose.yml
   ports:
     - "0.0.0.0:5432:5432"  # Good - binds to all
     - "127.0.0.1:5432:5432"  # Bad - local only
   ```

2. Check firewall:
   ```bash
   # On Terramaster
   sudo ufw status
   sudo ufw allow 5432/tcp
   sudo ufw allow 6379/tcp
   sudo ufw allow 7474/tcp
   sudo ufw allow 7687/tcp
   ```

### Subnet Issues
Your 10GbE network should have all devices on the same subnet. Verify:
```powershell
# On Windows
ipconfig | findstr "IPv4"

# Should show something like:
# 192.168.1.x (same first 3 octets as Terramaster)
```

## Performance Tips

With your 10GbE network:
- Expect <1ms latency to Terramaster
- Use jumbo frames if configured: `ping terramaster.local -f -l 8972`
- Consider dedicated VLAN for MCP traffic if needed

## Next Steps

1. Run the connectivity test
2. Choose connection method (direct vs SSH)
3. Update Claude Desktop config
4. Restart Claude Desktop
5. Test with: "Show me my available MCP tools"

All your Claude instances will now share the same:
- 🧠 Memory/Knowledge Graph
- 📁 File System
- 🗄️ Database State
- 🔧 Tool Configurations