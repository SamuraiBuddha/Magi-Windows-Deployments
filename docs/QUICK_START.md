# 🚀 Windows 11 Pro Deployment Quick Start

## Overview
This guide helps you quickly deploy Windows 11 Pro to the three Magi workstations using modern deployment methods.

## Prerequisites Checklist

- [ ] Windows 11 Pro ISO or installation media
- [ ] Product keys for each machine
- [ ] Network access (10GbE preferred)
- [ ] USB drive (16GB+) for WinPE boot
- [ ] Access to deployment server or network share

## Quick Deployment Steps

### 1. Prepare Deployment Environment
```powershell
# Run on deployment server
cd scripts
.\Deploy-Windows11.ps1 -PrepareEnvironment
```

### 2. Deploy to Each Machine

#### Melchior (Visual Computing)
```powershell
.\Deploy-Windows11.ps1 -ConfigFile "configs\melchior-config.xml" -MachineName "MELCHIOR"
```

#### Balthazar (AI Host)
```powershell
.\Deploy-Windows11.ps1 -ConfigFile "configs\balthazar-config.xml" -MachineName "BALTHAZAR"
```

#### Caspar (Code Generation)
```powershell
.\Deploy-Windows11.ps1 -ConfigFile "configs\caspar-config.xml" -MachineName "CASPAR"
```

### 3. Post-Deployment Configuration
```powershell
# Run on each machine after deployment
.\Post-Deploy-Config.ps1
```

## Network Boot Option (PXE)

1. Set up WDS/MDT server on your network
2. Configure DHCP options 66 & 67
3. Boot machines via F12/Network Boot
4. Select appropriate task sequence

## USB Boot Option

1. Create bootable USB with deployment tools:
```powershell
.\Create-DeploymentUSB.ps1 -USBDrive "E:" -IncludeDrivers
```

2. Boot from USB and run deployment

## Automated Driver Installation

Drivers are automatically installed based on hardware detection:
- NVIDIA drivers (RTX 3090, A5000, A4000)
- Intel chipset drivers
- AMD chipset drivers (Ryzen system)
- Network drivers (10GbE)

## Quick Troubleshooting

### Deployment Fails
- Check network connectivity
- Verify product key
- Ensure UEFI/Secure Boot settings correct

### Drivers Not Installing
- Update driver repository
- Check WMI queries in config
- Manually run driver injection

### Performance Issues
- Verify power plan set to High Performance
- Check GPU drivers installed correctly
- Confirm RAM running at rated speed

## Verification Commands

```powershell
# Check deployment status
Get-DeploymentStatus -MachineName "MELCHIOR"

# Verify drivers
Get-InstalledDrivers | Where-Object {$_.Status -ne "OK"}

# Check activation
slmgr /xpr

# Verify GPU
Get-WmiObject Win32_VideoController | Select Name, Status
```

## Next Steps

1. Install CORTEX stack components
2. Configure Docker Desktop
3. Set up development environments
4. Install professional software (Autodesk suite, etc.)

## Support

For issues or questions:
- Check logs in `C:\Windows\Logs\Deployment`
- Review event viewer for errors
- Consult the full deployment guide in `/docs`