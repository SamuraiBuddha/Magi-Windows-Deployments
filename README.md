# 🧠 Magi Windows Deployments

Modern Windows 11 Pro deployment configurations for three specialized workstations named after the Three Wise Men, each bringing unique computational gifts to the CORTEX project.

## 📚 Modern Deployment Evolution

### Then (2009) vs Now (2025)

| Old School (2009) | Modern Approach (2025) |
|-------------------|------------------------|
| Norton Ghost / Acronis | Windows ADK + MDT |
| Monolithic Images | Layered Provisioning |
| Manual Updates | Windows Autopilot |
| Sysprep Nightmares | PowerShell DSC |
| DVD/USB Distribution | Cloud-Based Deployment |
| One Image Per Config | Dynamic Configuration |

## 🎯 Deployment Strategy

We'll use a **hybrid approach** combining the best of modern methods:

1. **Base Layer**: Minimal Windows 11 Pro image (using MDT)
2. **Configuration Layer**: PowerShell DSC for system settings
3. **Software Layer**: Chocolatey/Winget for application deployment
4. **Customization Layer**: Role-specific configurations

## 🖥️ The Three Magi Workstations

### 🏛️ Melchior - CAD/3D Processing Station
**Hardware**: i9 11th Gen + RTX 3090 + 64GB RAM
**Role**: Digital craftsmanship and precision engineering
**Gift**: Gold (enduring technical excellence)

**Software Stack**:
- Autodesk Suite (AutoCAD, Revit, Navisworks, Recap, Civil 3D, 3ds Max)
- SolidWorks
- Point Cloud Processing Tools
- NVIDIA Studio Drivers
- Docker Desktop for CAD containers

### 🔮 Balthazar - AI Model Host
**Hardware**: i9 11th Gen + RTX A5000 + 128GB RAM  
**Role**: Intelligence elevation and model serving
**Gift**: Frankincense (transforming data into insights)

**Software Stack**:
- CUDA Toolkit & cuDNN
- Docker Desktop with GPU support
- Ollama for local LLMs
- Stable Diffusion WebUI
- PyTorch/TensorFlow environments
- VS Code with AI extensions
- WSL2 with Ubuntu for Linux AI tools

### ⚗️ Caspar - Code Generation & Data Processing
**Hardware**: Ryzen 9 5950X + RTX A4000 + 128GB RAM
**Role**: Systematic transformation and automation
**Gift**: Myrrh (preserving and transforming processes)

**Software Stack**:
- Full development environment (VS Code, JetBrains suite)
- Docker Desktop
- WSL2 with multiple distros
- Database tools (PostgreSQL, MongoDB, Neo4j clients)
- Data processing frameworks
- Git, Node.js, Python, Go, Rust toolchains

## 🗄️ Terramaster NAS Integration

### Centralized MCP Services
The **Terramaster F8 Plus** (16TB NVMe, TOS 6.0) hosts all MCP (Model Context Protocol) services, providing:
- **Unified Memory**: Single knowledge graph across all Claude instances
- **Consistent State**: Shared conversation context between machines
- **High Performance**: NVMe storage for fast MCP operations
- **Central Management**: Update all MCP tools in one place

**Hosted Services**:
- PostgreSQL (persistent storage)
- Redis (caching & pub/sub)
- Neo4j (knowledge graph)
- InfluxDB (metrics)
- MCP Manager (orchestration)

[See full Terramaster MCP setup guide](docs/TERRAMASTER_MCP_INTEGRATION.md)

## 🚀 Modern Deployment Methods

### Option 1: Microsoft Deployment Toolkit (MDT) - Recommended
**Pros**: Free, powerful, Microsoft-supported, works offline
**Cons**: Learning curve, requires deployment server

### Option 2: Windows Autopilot + Intune
**Pros**: Cloud-based, zero-touch deployment, modern
**Cons**: Requires Azure AD, subscription costs

### Option 3: Ansible + WinRM
**Pros**: Infrastructure as Code, version controlled, repeatable
**Cons**: Requires Linux control node, complex setup

### Option 4: Custom PowerShell + Chocolatey
**Pros**: Simple, scriptable, no infrastructure needed
**Cons**: Less sophisticated, manual USB/network deployment

## 📁 Repository Structure

```
Magi-Windows-Deployments/
├── base-image/
│   ├── windows-11-pro-base.md       # Base image creation guide
│   ├── drivers/                     # Common drivers
│   └── updates/                     # Cumulative updates
├── configurations/
│   ├── melchior-config.xml          # CAD workstation config
│   ├── balthazar-config.xml         # AI host config
│   └── caspar-config.xml            # Dev workstation config
├── scripts/
│   ├── Deploy-Windows11.ps1         # Main deployment script
│   ├── Setup-CORTEX-Integration.ps1 # CORTEX stack setup
│   ├── Configure-TerramasterMCP-Client.ps1 # MCP client config
│   └── deploy-mcp-terramaster.sh    # Terramaster setup
├── docs/
│   ├── QUICK_START.md
│   ├── TERRAMASTER_MCP_INTEGRATION.md
│   └── network-deployment.md
└── configs/
    └── network-deployment.md
```

## 📋 Quick Start

### Prerequisites
- Windows 11 Pro ISO (latest version)
- 32GB+ USB drive
- Windows ADK installed on a deployment machine
- PowerShell 7+

### Basic Deployment Flow
```powershell
# 1. Deploy Windows to target machine
.\scripts\Deploy-Windows11.ps1 -ConfigFile "configs\melchior-config.xml"

# 2. Configure drivers
.\scripts\Manage-Drivers.ps1 -Machine "Melchior"

# 3. Setup CORTEX integration
.\scripts\Setup-CORTEX-Integration.ps1 -Machine "Melchior"

# 4. Configure MCP connection to Terramaster
.\scripts\Configure-TerramasterMCP-Client.ps1 -TerramasterHost "terramaster.local"
```

## 🎯 Next Steps

1. **Setup Terramaster MCP Services** (centralized Claude memory)
2. **Create base Windows 11 Pro image**
3. **Deploy to each machine**
4. **Configure CORTEX integration**
5. **Test inter-machine orchestration**

## 📊 Deployment Checklist

- [ ] Windows 11 Pro licenses (3x)
- [ ] Latest Windows 11 ISO downloaded
- [ ] Drivers collected for each machine
- [ ] Software installers/licenses gathered
- [ ] Network infrastructure ready
- [ ] Terramaster MCP services deployed
- [ ] Backup current systems
- [ ] Test deployment environment

## 🔗 Resources

- [Microsoft Deployment Toolkit (MDT)](https://docs.microsoft.com/en-us/windows/deployment/deploy-windows-mdt/get-started-with-the-microsoft-deployment-toolkit)
- [Windows ADK](https://docs.microsoft.com/en-us/windows-hardware/get-started/adk-install)
- [PowerShell DSC](https://docs.microsoft.com/en-us/powershell/scripting/dsc/overview)
- [Chocolatey for Business](https://chocolatey.org/solutions/businesses)
- [Windows Autopilot](https://docs.microsoft.com/en-us/mem/autopilot/)
- [CORTEX AI Orchestrator](https://github.com/SamuraiBuddha/CORTEX-AI-Orchestrator-v2)

---

*Each machine named to honor the gifts of expertise: Melchior's astronomical precision, Balthazar's transformative wisdom, and Caspar's philosophical synthesis.*