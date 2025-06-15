# Melchior CAD/3D Workstation Configuration

## Hardware Profile
- **CPU**: Intel Core i9-11900K (11th Gen)
- **GPU**: NVIDIA GeForce RTX 3090
- **RAM**: 64GB DDR4-4600 (G.Skill TridentZ)
- **Motherboard**: ASUS ROG Strix Z590-E Gaming WiFi
- **Storage**: NVMe SSDs for OS and projects
- **PSU**: 1200W Thor

## Software Stack

### Core CAD/3D Applications
```xml
<?xml version="1.0" encoding="utf-8"?>
<packages>
  <!-- Autodesk Suite -->
  <package id="autodesk-autocad" version="2025" />
  <package id="autodesk-revit" version="2025" />
  <package id="autodesk-navisworks" version="2025" />
  <package id="autodesk-recap" version="2025" />
  <package id="autodesk-civil3d" version="2025" />
  <package id="autodesk-3dsmax" version="2025" />
  
  <!-- SolidWorks -->
  <package id="solidworks-premium" version="2024" />
  
  <!-- Supporting Tools -->
  <package id="cloudcompare" />
  <package id="meshlab" />
  <package id="blender" />
  <package id="rhino7" />
</packages>
```

### System Tools (Chocolatey)
```powershell
# Install via Chocolatey
choco install nvidia-display-driver
choco install 7zip
choco install notepadplusplus
choco install firefox
choco install vlc
choco install windirstat
choco install everything
choco install powertoys
```

### Development Tools
```powershell
# For CAD automation and scripting
choco install python
choco install vscode
choco install git
choco install docker-desktop
```

## System Configuration

### NVIDIA Settings
```powershell
# Set to NVIDIA Studio Driver
# Enable GPU scheduling
# Configure for single display performance
# Set power management to "Prefer maximum performance"
```

### Windows Settings
```powershell
# Disable Windows Updates during work hours
$UpdateHours = @{
    Start = "08:00"
    End = "18:00"
}

# Set Visual Effects for Performance
SystemPropertiesPerformance.exe

# Disable unnecessary services
Set-Service -Name "Windows Search" -StartupType Disabled
Set-Service -Name "SysMain" -StartupType Disabled
```

### Power Profile
```powershell
# Create High Performance profile for CAD work
powercfg -duplicatescheme 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c

# Disable USB selective suspend
powercfg -change -usb-selective-suspend-enable off

# Never turn off displays
powercfg -change -monitor-timeout-ac 0
powercfg -change -monitor-timeout-dc 0
```

## Network Configuration

### SMB Settings for NAS
```powershell
# Enable SMB 3.0
Enable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -All

# Map network drives
New-PSDrive -Name "P" -PSProvider FileSystem -Root "\\TERRAMASTER\Projects" -Persist
New-PSDrive -Name "L" -PSProvider FileSystem -Root "\\TERRAMASTER\Library" -Persist
```

### 10GbE Optimization
```powershell
# Set Jumbo Frames
Set-NetAdapterAdvancedProperty -Name "Ethernet" -DisplayName "Jumbo Packet" -DisplayValue "9014 Bytes"

# Optimize for throughput
Set-NetAdapterRss -Name "Ethernet" -Enabled $true
Set-NetAdapterReceiveScaling -Name "Ethernet" -Enabled $true
```

## Scheduled Tasks

### Daily Maintenance
```powershell
# Create scheduled task for overnight optimization
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-File C:\Scripts\NightlyMaintenance.ps1"
$trigger = New-ScheduledTaskTrigger -Daily -At 3:00AM
Register-ScheduledTask -TaskName "MelchiorMaintenance" -Action $action -Trigger $trigger
```

### Project Backup
```powershell
# Backup active projects to NAS
$backupScript = @'
robocopy C:\Projects \\TERRAMASTER\Backups\Melchior\Projects /MIR /R:3 /W:10 /MT:16
'@
```

## Performance Optimizations

### GPU Settings
```powershell
# NVIDIA Control Panel Settings
# - Power management mode: Prefer maximum performance
# - Texture filtering quality: High performance
# - Threaded optimization: On
# - Vertical sync: Off
```

### RAM Disk for Temp Files
```powershell
# Create 8GB RAM disk for CAD temp files
# Use ImDisk or similar tool
# Redirect Autodesk temp folders to RAM disk
```

## Docker Configuration

### CAD-Specific Containers
```yaml
version: '3.8'
services:
  pointcloud-processor:
    image: pdal/pdal:latest
    volumes:
      - C:\Projects:/data
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: 1
              capabilities: [gpu]
```

## Monitoring

### Performance Counters
- GPU Usage and Temperature
- RAM Usage by Process
- Disk Queue Length
- Network Throughput

### Alerts
- GPU Temperature > 80°C
- RAM Usage > 90%
- Disk Space < 20%
- License Server Connectivity