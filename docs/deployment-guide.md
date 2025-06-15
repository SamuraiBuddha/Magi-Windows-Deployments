# Quick Deployment Guide

## Prerequisites Checklist
- [ ] Windows 11 Pro ISO downloaded
- [ ] 3 machines ready for deployment
- [ ] All software licenses available
- [ ] Network configured (10GbE operational)
- [ ] Backup of any existing data completed

## Deployment Options

### Option 1: PowerShell + Chocolatey (Simplest)
Best for: Quick deployment without infrastructure

1. Install Windows 11 Pro manually
2. Run PowerShell as Administrator
3. Execute deployment script:
```powershell
# Download deployment scripts
git clone https://github.com/SamuraiBuddha/Magi-Windows-Deployments.git
cd Magi-Windows-Deployments

# Deploy each machine
.\scripts\Deploy-Magi.ps1 -Role "Melchior" -ComputerName "MELCHIOR-CAD"
.\scripts\Deploy-Magi.ps1 -Role "Balthazar" -ComputerName "BALTHAZAR-AI"  
.\scripts\Deploy-Magi.ps1 -Role "Caspar" -ComputerName "CASPAR-CODE"
```

### Option 2: MDT (Recommended for repeatability)
Best for: Multiple deployments, standardization

1. Set up MDT server (can be on existing machine)
2. Create base Windows 11 image
3. Import role-specific task sequences
4. PXE boot target machines
5. Select appropriate task sequence

### Option 3: Ansible + WinRM (Infrastructure as Code)
Best for: Version control, automation

1. Set up Ansible control node (WSL2 or Linux VM)
2. Configure WinRM on Windows machines
3. Run playbooks:
```bash
ansible-playbook -i inventory.yml deploy-melchior.yml
ansible-playbook -i inventory.yml deploy-balthazar.yml
ansible-playbook -i inventory.yml deploy-caspar.yml
```

## Post-Deployment Tasks

### All Machines
1. Join domain/workgroup
2. Configure Windows Hello/BitLocker
3. Install Windows updates
4. Configure backup solution
5. Test network connectivity to NAS

### Melchior (CAD)
1. Install Autodesk suite with network license
2. Configure GPU for CAD performance
3. Set up project templates
4. Map network drives for projects

### Balthazar (AI)
1. Install CUDA drivers
2. Pull LLM models with Ollama
3. Configure Stable Diffusion
4. Set up model serving endpoints

### Caspar (Code)
1. Configure Git credentials
2. Clone repositories
3. Set up development databases
4. Configure IDE settings

## Verification Checklist

### System Health
- [ ] All Windows features enabled
- [ ] No errors in Event Viewer
- [ ] All drivers installed correctly
- [ ] Network speeds at 10Gbps

### Software
- [ ] All Chocolatey packages installed
- [ ] Docker Desktop running
- [ ] WSL2 operational (where applicable)
- [ ] Role-specific apps functional

### Performance
- [ ] CPU boost enabled
- [ ] GPU recognized and configured
- [ ] RAM running at rated speed
- [ ] NVMe drives benchmarking correctly

## Troubleshooting

### Common Issues

**Windows 11 Requirements**
- TPM 2.0 must be enabled in BIOS
- Secure Boot must be supported
- UEFI mode required

**Network Issues**
- Check jumbo frames configuration
- Verify 10GbE driver version
- Test with iperf3 between machines

**GPU Not Detected**
- Reseat GPU
- Check power connectors
- Update motherboard BIOS
- Try different PCIe slot

**Docker Desktop Won't Start**
- Enable virtualization in BIOS
- Ensure Hyper-V is enabled
- Check for WSL2 updates

## Support Resources

- [Microsoft Deployment Toolkit](https://docs.microsoft.com/en-us/windows/deployment/)
- [Chocolatey Documentation](https://docs.chocolatey.org/)
- [Docker Desktop Troubleshooting](https://docs.docker.com/desktop/troubleshooting/)
- [NVIDIA Driver Downloads](https://www.nvidia.com/download/index.aspx)
- [AMD Chipset Drivers](https://www.amd.com/en/support)

## Contact
For questions about this deployment:
- Repository: https://github.com/SamuraiBuddha/Magi-Windows-Deployments
- Create an issue for problems or suggestions