# 📋 MCP Services Quick Reference

## 🔴 Essential Services (Start These First)

| Service | Purpose | Port | Required Config |
|---------|---------|------|-----------------|
| **mcp-redis** | Caching, pub/sub, fast key-value store | 6379 | REDIS_PASSWORD |
| **mcp-postgres** | Primary database for persistent storage | 5432 | POSTGRES_PASSWORD |
| **mcp-filesystem** | Shared file access across all Claude instances | - | Volume mounts |
| **mcp-basic-memory** | Simple persistent memory for Claude | - | None |

## 🟡 Highly Recommended

| Service | Purpose | Port | Required Config |
|---------|---------|------|-----------------|
| **mcp-github** | GitHub integration for code repos | - | GITHUB_TOKEN |
| **mcp-desktop-commander** | Advanced file operations | - | Volume mounts |
| **mcp-neo4j-memory** | Knowledge graph memory | 7474/7687 | NEO4J_PASSWORD |
| **mcp-sequential-thinking** | Advanced reasoning chains | - | None |
| **portainer** | Docker management UI | 9000 | None |

## 🟢 Optional but Useful

| Service | Purpose | Required Config |
|---------|---------|-----------------|
| **mcp-node-sandbox** | Safe code execution environment | Docker socket |
| **mcp-docker** | Docker management from Claude | Docker socket |
| **mcp-fetch** | Web content fetching | None |
| **mcp-time** | Time/timezone conversions | DEFAULT_TIMEZONE |
| **mcp-context7** | Library documentation | CONTEXT7_API_KEY |
| **mcp-atlas-docs** | Atlas documentation | None |

## 🔵 Specialized Services

### AI & Search
| Service | Purpose | Required Config |
|---------|---------|-----------------|
| **mcp-paper-search** | Academic paper search | SEMANTIC_SCHOLAR_API_KEY (optional) |
| **mcp-perplexity** | Perplexity AI search | PERPLEXITY_API_KEY |
| **mcp-youtube-transcript** | YouTube video transcripts | YOUTUBE_API_KEY |

### Productivity
| Service | Purpose | Required Config |
|---------|---------|-----------------|
| **mcp-notion** | Notion workspace integration | NOTION_TOKEN |
| **mcp-everart** | Everart platform integration | EVERART_API_KEY |
| **mcp-osp-marketing** | Marketing tools | None |

### Infrastructure
| Service | Purpose | Required Config |
|---------|---------|-----------------|
| **mcp-grafana** | Grafana dashboard integration | GRAFANA_API_KEY |
| **mcp-pinecone** | Vector database | PINECONE_API_KEY |
| **mcp-azure** | Azure cloud services | AZURE_* credentials |

### Automation
| Service | Purpose | Required Config |
|---------|---------|-----------------|
| **mcp-playwright** | Browser automation | None |
| **mcp-everything** | Windows Everything search | EVERYTHING_HOST |
| **mcp-3d-printer** | 3D printer control | OCTOPRINT_URL/API_KEY |

## 🚀 Minimal Setup (Just the Essentials)

```bash
# Start only core services
docker-compose up -d \
  mcp-redis \
  mcp-postgres \
  mcp-filesystem \
  mcp-basic-memory \
  mcp-github
```

## 💻 Machine-Specific Recommendations

### Melchior (CAD/3D)
- Essential: All core services
- Recommended: `mcp-filesystem`, `mcp-3d-printer`
- Optional: `mcp-everart`

### Balthazar (AI Host)
- Essential: All core services
- Recommended: `mcp-neo4j-memory`, `mcp-sequential-thinking`
- Optional: `mcp-paper-search`, `mcp-perplexity`

### Caspar (Code Generation)
- Essential: All core services
- Recommended: `mcp-github`, `mcp-node-sandbox`, `mcp-docker`
- Optional: `mcp-context7`, `mcp-atlas-docs`

## 📊 Resource Usage Estimates

| Service Type | RAM Usage | CPU Usage | Disk Space |
|--------------|-----------|-----------|------------|
| Databases | 2-4GB each | Low-Medium | Grows over time |
| Memory Services | 1-2GB each | Low | Depends on usage |
| API Integrations | <500MB each | Low | Minimal |
| Automation Tools | 1-2GB each | Medium-High | Minimal |

## 🔧 Quick Commands

```bash
# Check what's running
docker-compose ps

# View logs for a service
docker-compose logs -f mcp-postgres

# Restart a service
docker-compose restart mcp-github

# Stop everything
docker-compose down

# Start everything
docker-compose up -d

# Update all images
docker-compose pull
docker-compose up -d
```

## 🌐 Network Requirements

All services bind to `0.0.0.0` (all interfaces) to be accessible from your Windows machines. Ensure your Terramaster firewall allows:
- TCP 5432 (PostgreSQL)
- TCP 6379 (Redis)
- TCP 7474 (Neo4j HTTP)
- TCP 7687 (Neo4j Bolt)
- TCP 9000 (Portainer)

## 💡 Tips

1. **Start Small**: Begin with essential services, add others as needed
2. **Monitor Resources**: Use `docker stats` to watch memory/CPU
3. **Check Logs**: Always check logs when adding new services
4. **Test Connectivity**: Use the test script from Windows before configuring Claude
5. **Document API Keys**: Keep a secure record of all your API keys