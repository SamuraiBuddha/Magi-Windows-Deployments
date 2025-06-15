# Caspar Code Generation & Data Processing Configuration

## Hardware Profile
- **CPU**: AMD Ryzen 9 5950X (16 cores, 32 threads)
- **GPU**: NVIDIA RTX A4000 (Professional GPU)
- **RAM**: 128GB DDR4-3600 (G.Skill TridentZ RGB)
- **Motherboard**: ASUS ROG Crosshair VIII Formula
- **Storage**: Multiple NVMe SSDs for code and data
- **PSU**: 1600W

## Software Stack

### Development Environment
```powershell
# Core Development Tools
choco install vscode
choco install visualstudio2022enterprise
choco install jetbrains-toolbox
choco install git
choco install gh
choco install docker-desktop

# Code Editors and IDEs
choco install notepadplusplus
choco install sublimetext4
choco install vim

# Database Tools
choco install dbeaver
choco install mongodb-compass
choco install pgadmin4
choco install redis-desktop-manager
```

### Programming Languages & Runtimes
```powershell
# Languages
choco install python --version=3.11.0
choco install nodejs-lts
choco install golang
choco install rust
choco install dotnet-sdk
choco install openjdk17
choco install php
choco install ruby

# Package Managers
choco install yarn
choco install pnpm
choco install pip
choco install poetry
```

### WSL2 Setup with Multiple Distros
```powershell
# Install WSL2
wsl --install
wsl --set-default-version 2

# Install multiple distributions
wsl --install -d Ubuntu-22.04
wsl --install -d Debian
wsl --install -d kali-linux
wsl --install -d Fedora-38

# Set Ubuntu as default
wsl --set-default Ubuntu-22.04
```

### Database Servers
```yaml
# docker-compose.yml for local databases
version: '3.8'
services:
  postgres:
    image: postgres:15
    environment:
      POSTGRES_PASSWORD: devpassword
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

  mongodb:
    image: mongo:7
    ports:
      - "27017:27017"
    volumes:
      - mongo_data:/data/db

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data

  neo4j:
    image: neo4j:5
    ports:
      - "7474:7474"
      - "7687:7687"
    environment:
      NEO4J_AUTH: neo4j/devpassword
    volumes:
      - neo4j_data:/data

  elasticsearch:
    image: elasticsearch:8.11.0
    environment:
      - discovery.type=single-node
      - xpack.security.enabled=false
    ports:
      - "9200:9200"
    volumes:
      - elastic_data:/usr/share/elasticsearch/data

volumes:
  postgres_data:
  mongo_data:
  redis_data:
  neo4j_data:
  elastic_data:
```

## System Configuration

### AMD CPU Optimization
```powershell
# Enable AMD Ryzen performance boost
powercfg -attributes SUB_PROCESSOR 7f2f5cfa-f10c-4823-b5e1-e93ae85f46b5 -ATTRIB_HIDE

# Set processor performance boost mode
powercfg -setacvalueindex SCHEME_CURRENT SUB_PROCESSOR 7f2f5cfa-f10c-4823-b5e1-e93ae85f46b5 2
powercfg -setactive SCHEME_CURRENT

# Enable all CPU cores
bcdedit /set numproc 32
```

### Development Environment Variables
```powershell
# Set development paths
[Environment]::SetEnvironmentVariable("GOPATH", "D:\Go", "User")
[Environment]::SetEnvironmentVariable("CARGO_HOME", "D:\Rust\.cargo", "User")
[Environment]::SetEnvironmentVariable("RUSTUP_HOME", "D:\Rust\.rustup", "User")
[Environment]::SetEnvironmentVariable("JAVA_HOME", "C:\Program Files\OpenJDK\jdk-17", "Machine")

# Node.js settings
[Environment]::SetEnvironmentVariable("NODE_OPTIONS", "--max-old-space-size=8192", "User")
```

### Git Configuration
```bash
# Global git config
git config --global user.name "Jordan Ehrig"
git config --global user.email "jordan@ehrigbim.com"
git config --global core.autocrlf input
git config --global core.editor "code --wait"
git config --global init.defaultBranch main

# Git aliases
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
git config --global alias.lg "log --oneline --graph --all"
```

## Development Tools Configuration

### VS Code Extensions
```json
{
  "recommendations": [
    "ms-vscode-remote.remote-wsl",
    "ms-vscode-remote.remote-containers",
    "ms-python.python",
    "golang.go",
    "rust-lang.rust-analyzer",
    "ms-dotnettools.csharp",
    "dbaeumer.vscode-eslint",
    "esbenp.prettier-vscode",
    "eamodio.gitlens",
    "github.copilot",
    "tabnine.tabnine-vscode",
    "ms-azuretools.vscode-docker",
    "hashicorp.terraform",
    "redhat.vscode-yaml",
    "ms-vscode.powershell"
  ]
}
```

### JetBrains Configuration
```powershell
# Install via JetBrains Toolbox
# - IntelliJ IDEA Ultimate
# - PyCharm Professional
# - WebStorm
# - GoLand
# - Rider
# - DataGrip
# - CLion
```

## Container Development

### Docker BuildKit
```json
{
  "features": {
    "buildkit": true
  },
  "experimental": true,
  "builder": {
    "gc": {
      "defaultKeepStorage": "20GB",
      "enabled": true
    }
  }
}
```

### Development Containers
```dockerfile
# Multi-language development container
FROM mcr.microsoft.com/devcontainers/universal:2

# Additional tools
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    clang \
    lldb \
    gdb \
    && rm -rf /var/lib/apt/lists/*
```

## Data Processing Tools

### Python Data Science Stack
```bash
conda create -n datascience python=3.11
conda activate datascience
conda install numpy pandas matplotlib seaborn scikit-learn
conda install jupyterlab ipywidgets
conda install dask distributed
conda install -c conda-forge apache-airflow
pip install polars duckdb pyarrow
```

### Big Data Tools
```powershell
# Apache Spark
choco install apache-spark

# Kafka
choco install kafka

# Hadoop (via WSL2)
wsl -d Ubuntu-22.04 -e bash -c "wget https://dlcdn.apache.org/hadoop/common/hadoop-3.3.6/hadoop-3.3.6.tar.gz"
```

## Performance Monitoring

### System Metrics
```powershell
# Install performance monitoring tools
choco install hwinfo
choco install cpu-z
choco install gpu-z
choco install crystaldiskmark
```

### Development Metrics
```powershell
# Git stats
git config --global alias.stats "shortlog -sn --all --no-merges"

# Code metrics
pip install radon
pip install pylint
npm install -g cloc
```

## Backup and Version Control

### Code Backup Strategy
```powershell
# Automated Git pushes
$gitBackup = @'
Get-ChildItem -Path D:\Projects -Directory | ForEach-Object {
    Push-Location $_.FullName
    if (Test-Path .git) {
        git add .
        git commit -m "Automated backup $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
        git push
    }
    Pop-Location
}
'@
```

### Database Backup
```bash
# PostgreSQL backup
docker exec postgres pg_dumpall -U postgres > backup_$(date +%Y%m%d).sql

# MongoDB backup
docker exec mongodb mongodump --out /backup/$(date +%Y%m%d)
```

## Network Configuration

### Development Ports
```powershell
# Common development ports
$ports = @(
    3000,  # React
    4200,  # Angular
    5000,  # Flask
    5173,  # Vite
    8000,  # Django
    8080,  # Spring Boot
    9000,  # PHP
    3306,  # MySQL
    5432,  # PostgreSQL
    27017, # MongoDB
    6379,  # Redis
    9200   # Elasticsearch
)

foreach ($port in $ports) {
    New-NetFirewallRule -DisplayName "Dev Port $port" -Direction Inbound -LocalPort $port -Protocol TCP -Action Allow
}
```