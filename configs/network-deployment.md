# Network Deployment Configuration

## WDS/MDT Server Configuration

### DHCP Options
- Option 66 (Boot Server): 192.168.1.10
- Option 67 (Boot File): boot\x64\wdsnbp.com

### Network Settings
- Deployment VLAN: 100
- Management VLAN: 1
- Storage VLAN: 200
- 10GbE Network Optimization: Enabled

## PXE Boot Configuration

### Boot Images
- LiteTouchPE_x64.wim - Main deployment image
- WinPE_Drivers_x64.wim - Driver injection image
- WinPE_Tools_x64.wim - Troubleshooting tools

### Task Sequences

#### TS001 - Melchior Visual Computing
- Image: WIN11PRO_VISUAL_x64
- Applications: Autodesk Suite, Visual Studio, NVIDIA Tools
- Drivers: RTX 3090, Intel Z590, 10GbE
- Post-Config: Enable GPU acceleration, configure displays

#### TS002 - Balthazar AI Host
- Image: WIN11PRO_AI_x64
- Applications: Docker Desktop, CUDA Toolkit, Python Suite
- Drivers: RTX A5000, Intel Z590, 10GbE
- Post-Config: WSL2, Docker configuration, GPU passthrough

#### TS003 - Caspar Code Generation
- Image: WIN11PRO_DEV_x64
- Applications: Development IDEs, Build Tools, Git
- Drivers: RTX A4000, AMD X570, 10GbE
- Post-Config: Dev environment setup, code repositories

## Network Share Structure

```
\\DEPLOYSERVER\DeploymentShare$
├── Applications
│   ├── Autodesk
│   ├── Development
│   ├── Docker
│   └── NVIDIA
├── Drivers
│   ├── Network
│   │   └── 10GbE
│   ├── Graphics
│   │   ├── RTX3090
│   │   ├── RTXA5000
│   │   └── RTXA4000
│   └── Chipset
│       ├── Intel
│       └── AMD
├── Operating Systems
│   └── Windows 11 Pro
└── Task Sequences
    ├── TS001_Melchior
    ├── TS002_Balthazar
    └── TS003_Caspar
```

## Multicast Configuration

### Multicast Settings
- Address Range: 239.1.1.1 - 239.1.1.10
- Port Range: 63000-63010
- TTL: 32
- Transmission Rate: Auto-adjust (10GbE capable)

### Session Configuration
```xml
<MulticastSession>
    <Name>MagiDeployment</Name>
    <TransmissionType>AutoCast</TransmissionType>
    <MinimumClients>1</MinimumClients>
    <MaximumClients>3</MaximumClients>
    <StartDelay>0</StartDelay>
    <Bandwidth>0</Bandwidth> <!-- 0 = unlimited for 10GbE -->
</MulticastSession>
```

## High-Performance Settings

### Network Optimization
- Jumbo Frames: 9000 MTU
- Receive Side Scaling: Enabled
- TCP Offload: Enabled
- Flow Control: Disabled

### Storage Optimization
- Block Size: 64KB
- Cache: Write-through
- Compression: Disabled (10GbE has bandwidth)

## Deployment Credentials

### Domain Join
- Domain: MAGI.LOCAL
- OU: OU=Workstations,DC=magi,DC=local
- Join Account: svc_deploy

### Local Admin
- Username: MagiAdmin
- Temporary Password: [Set in deployment]
- Force Change: Yes

## Monitoring

### Performance Counters
- Network Utilization
- Disk Queue Length
- Memory Usage
- CPU Usage

### Log Locations
- WDS: C:\Windows\System32\WDS\Logs
- MDT: C:\DeploymentShare\Logs
- Client: X:\Windows\Temp\DeploymentLogs

## Troubleshooting Network Boot

### Common Issues

1. **PXE-E53: No boot filename received**
   - Check DHCP options 66 & 67
   - Verify WDS service running

2. **Slow deployment over 10GbE**
   - Check jumbo frames enabled
   - Verify switch configuration
   - Test with iperf3

3. **Multicast not working**
   - Enable IGMP snooping on switches
   - Check firewall rules
   - Verify multicast routing

### Network Test Commands
```powershell
# Test network speed
iperf3 -c DEPLOYSERVER -P 4 -t 30

# Check MTU
ping DEPLOYSERVER -f -l 8972

# Verify multicast
mctest -s 239.1.1.1:63000
```