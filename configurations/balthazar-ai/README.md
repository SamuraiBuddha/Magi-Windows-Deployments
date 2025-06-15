# Balthazar AI Host Configuration

## Hardware Profile
- **CPU**: Intel Core i9-11900K (11th Gen)
- **GPU**: NVIDIA RTX A5000 (Professional GPU)
- **RAM**: 128GB DDR4-3600 (G.Skill TridentZ Neo)
- **Motherboard**: ASUS ROG Maximus XIII Hero
- **Storage**: Multiple NVMe SSDs for models and datasets
- **PSU**: 1200W Thor

## Software Stack

### AI/ML Frameworks
```powershell
# NVIDIA Foundation
choco install cuda --version=12.2.0
choco install cudnn

# Python Environment
choco install python --version=3.11.0
choco install miniconda3

# Core Development
choco install vscode
choco install git
choco install docker-desktop
```

### WSL2 Configuration
```powershell
# Enable WSL2
wsl --install
wsl --set-default-version 2

# Install Ubuntu 22.04
wsl --install -d Ubuntu-22.04

# Configure GPU support in WSL2
wsl --update
```

### Docker Configuration
```yaml
# daemon.json for Docker Desktop
{
  "features": {
    "buildkit": true
  },
  "default-runtime": "nvidia",
  "runtimes": {
    "nvidia": {
      "path": "nvidia-container-runtime",
      "runtimeArgs": []
    }
  },
  "data-root": "D:\\Docker",
  "storage-driver": "windowsfilter",
  "max-concurrent-downloads": 10,
  "max-concurrent-uploads": 10
}
```

### AI Model Hosting Setup

#### Ollama Installation
```powershell
# Install Ollama for Windows
Invoke-WebRequest -Uri "https://ollama.ai/download/windows" -OutFile "ollama-windows.exe"
.\ollama-windows.exe

# Set model storage path
$env:OLLAMA_MODELS = "D:\AI\Models\Ollama"
```

#### Local LLM Models
```bash
# Download models
ollama pull llama3.1:70b
ollama pull codellama:34b
ollama pull mistral:latest
ollama pull deepseek-coder:33b
ollama pull qwen2.5:32b
```

#### Stable Diffusion Setup
```powershell
# Clone and setup
git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git D:\AI\stable-diffusion-webui
cd D:\AI\stable-diffusion-webui

# Install with optimizations
.\webui.bat --xformers --opt-sdp-attention --medvram
```

### Development Environments

#### PyTorch Environment
```bash
conda create -n pytorch python=3.11
conda activate pytorch
conda install pytorch torchvision torchaudio pytorch-cuda=12.1 -c pytorch -c nvidia
pip install transformers accelerate bitsandbytes
```

#### TensorFlow Environment
```bash
conda create -n tensorflow python=3.11
conda activate tensorflow
pip install tensorflow[and-cuda]
pip install keras tensorflow-hub
```

#### LangChain Environment
```bash
conda create -n langchain python=3.11
conda activate langchain
pip install langchain langchain-community langchain-experimental
pip install chromadb sentence-transformers
pip install openai anthropic
```

## System Configuration

### GPU Optimization
```powershell
# NVIDIA Settings
# - Enable GPU Performance Counters
# - Set GPU to TCC mode (if supported)
# - Configure Multi-Instance GPU (MIG) if needed

# Set environment variables
[Environment]::SetEnvironmentVariable("CUDA_VISIBLE_DEVICES", "0", "Machine")
[Environment]::SetEnvironmentVariable("TF_FORCE_GPU_ALLOW_GROWTH", "true", "Machine")
```

### Memory Configuration
```powershell
# Enable large pages
fsutil behavior set memoryusage 2

# Set pagefile to fixed size
wmic computersystem set AutomaticManagedPagefile=False
wmic pagefileset where name="C:\\pagefile.sys" set InitialSize=32768,MaximumSize=32768
```

### Network Optimization for Model Serving
```powershell
# Open ports for model serving
New-NetFirewallRule -DisplayName "Ollama API" -Direction Inbound -LocalPort 11434 -Protocol TCP -Action Allow
New-NetFirewallRule -DisplayName "Stable Diffusion WebUI" -Direction Inbound -LocalPort 7860 -Protocol TCP -Action Allow
New-NetFirewallRule -DisplayName "Text Generation WebUI" -Direction Inbound -LocalPort 7861 -Protocol TCP -Action Allow
```

## Container Templates

### LLM Inference Container
```dockerfile
FROM nvidia/cuda:12.2.0-runtime-ubuntu22.04

RUN apt-get update && apt-get install -y \
    python3-pip \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt

EXPOSE 8000
CMD ["python", "server.py"]
```

### Model Training Container
```yaml
version: '3.8'
services:
  training:
    build: .
    runtime: nvidia
    environment:
      - NVIDIA_VISIBLE_DEVICES=all
    volumes:
      - D:\AI\datasets:/data
      - D:\AI\models:/models
    shm_size: '64gb'
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: 1
              capabilities: [gpu]
```

## Monitoring and Management

### GPU Monitoring
```powershell
# Install nvidia-ml-py
pip install nvidia-ml-py3

# Create monitoring script
$monitorScript = @'
import pynvml
import time
import json

pynvml.nvmlInit()
handle = pynvml.nvmlDeviceGetHandleByIndex(0)

while True:
    info = {
        "temperature": pynvml.nvmlDeviceGetTemperature(handle, 0),
        "power": pynvml.nvmlDeviceGetPowerUsage(handle) / 1000,
        "memory": pynvml.nvmlDeviceGetMemoryInfo(handle),
        "utilization": pynvml.nvmlDeviceGetUtilizationRates(handle)
    }
    print(json.dumps(info))
    time.sleep(5)
'@
```

### Model Management
```powershell
# Directory structure
New-Item -ItemType Directory -Path @(
    "D:\AI\Models\Ollama",
    "D:\AI\Models\Diffusion",
    "D:\AI\Models\Custom",
    "D:\AI\Datasets",
    "D:\AI\Checkpoints",
    "D:\AI\Cache"
)
```

## Scheduled Tasks

### Model Updates
```powershell
# Weekly model updates
$updateScript = @'
ollama pull --all
cd D:\AI\stable-diffusion-webui
git pull
'@
```

### Cache Cleanup
```powershell
# Clear old model caches
$cleanupScript = @'
Remove-Item -Path "D:\AI\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue
Get-ChildItem -Path "D:\AI\Checkpoints" -Recurse | Where-Object {$_.LastWriteTime -lt (Get-Date).AddDays(-30)} | Remove-Item
'@
```

## Performance Benchmarks

### Expected Performance
- Llama 3.1 70B: ~15 tokens/sec (4-bit quantized)
- Stable Diffusion XL: ~3 sec/image (512x512)
- Training: ~500 samples/sec (BERT fine-tuning)