# Base Windows 11 Pro Image Creation Guide

## Overview
This guide walks through creating a clean, optimized Windows 11 Pro base image that will be customized for each Magi workstation.

## Prerequisites
- Windows 11 Pro ISO (latest build)
- Windows Assessment and Deployment Kit (ADK)
- Microsoft Deployment Toolkit (MDT)
- Hyper-V or VMware for testing

## Step 1: Install Windows ADK and MDT

```powershell
# Download and install Windows ADK
# https://go.microsoft.com/fwlink/?linkid=2196127

# Download and install MDT
# https://www.microsoft.com/en-us/download/details.aspx?id=54259
```

## Step 2: Create MDT Deployment Share

```powershell
# Create deployment share
New-Item -Path "C:\DeploymentShare" -ItemType Directory
New-SmbShare -Name "DeploymentShare$" -Path "C:\DeploymentShare" -FullAccess "Everyone"

# Import Windows 11 Pro media
Import-MDTOperatingSystem -Path "DS001:\Operating Systems" -SourcePath "D:\" -DestinationFolder "Windows 11 Pro x64"
```

## Step 3: Create Task Sequence

Create a standard client task sequence with these settings:
- Task sequence ID: WIN11-BASE
- Task sequence name: Windows 11 Pro Base Image
- Select "Standard Client Task Sequence"
- Select the Windows 11 Pro operating system
- Do not specify a product key (will activate with digital license)
- Organization name: Magi Systems
- Internet Explorer home page: about:blank

## Step 4: Customize Task Sequence

### Disable Unnecessary Features
```xml
<DisableWindowsFeatures>
  <Feature>WindowsMediaPlayer</Feature>
  <Feature>WorkFolders-Client</Feature>
  <Feature>Printing-XPSServices-Features</Feature>
</DisableWindowsFeatures>
```

### Enable Required Features
```xml
<EnableWindowsFeatures>
  <Feature>Microsoft-Windows-Subsystem-Linux</Feature>
  <Feature>VirtualMachinePlatform</Feature>
  <Feature>Microsoft-Hyper-V-All</Feature>
  <Feature>Containers</Feature>
</EnableWindowsFeatures>
```

## Step 5: Unattend.xml Customizations

```xml
<?xml version="1.0" encoding="utf-8"?>
<unattend xmlns="urn:schemas-microsoft-com:unattend">
    <settings pass="specialize">
        <component name="Microsoft-Windows-Shell-Setup">
            <ComputerName>*</ComputerName>
            <RegisteredOrganization>Magi Systems</RegisteredOrganization>
            <RegisteredOwner>Jordan Ehrig</RegisteredOwner>
            <TimeZone>Eastern Standard Time</TimeZone>
        </component>
        <component name="Microsoft-Windows-Deployment">
            <RunSynchronous>
                <RunSynchronousCommand>
                    <Order>1</Order>
                    <Path>cmd /c reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v DoNotConnectToWindowsUpdateInternetLocations /t REG_DWORD /d 1 /f</Path>
                    <Description>Disable Windows Update during deployment</Description>
                </RunSynchronousCommand>
            </RunSynchronous>
        </component>
    </settings>
    <settings pass="oobeSystem">
        <component name="Microsoft-Windows-Shell-Setup">
            <OOBE>
                <HideEULAPage>true</HideEULAPage>
                <HideLocalAccountScreen>true</HideLocalAccountScreen>
                <HideOEMRegistrationScreen>true</HideOEMRegistrationScreen>
                <HideOnlineAccountScreens>true</HideOnlineAccountScreens>
                <HideWirelessSetupInOOBE>true</HideWirelessSetupInOOBE>
                <ProtectYourPC>1</ProtectYourPC>
            </OOBE>
            <UserAccounts>
                <LocalAccounts>
                    <LocalAccount wcm:action="add">
                        <Password>
                            <Value>TempPass123!</Value>
                            <PlainText>true</PlainText>
                        </Password>
                        <Description>Local Administrator</Description>
                        <DisplayName>MagiAdmin</DisplayName>
                        <Group>Administrators</Group>
                        <Name>MagiAdmin</Name>
                    </LocalAccount>
                </LocalAccounts>
            </UserAccounts>
        </component>
    </settings>
</unattend>
```

## Step 6: Add Universal Drivers

Download and add these driver packs to MDT:
- Intel Chipset drivers
- Intel RST drivers  
- Realtek Audio drivers
- Intel/Realtek network drivers

Place in: `DeploymentShare\Out-of-Box Drivers`

## Step 7: Build and Capture

1. Update the deployment share
2. Create boot media
3. Deploy to a VM
4. Capture the image using MDT

```powershell
# Update deployment share
Update-MDTDeploymentShare -Path "DS001:" -Force

# The captured image will be in:
# DeploymentShare\Captures\WIN11-BASE.wim
```

## Step 8: Optimize Image

```powershell
# Mount the image
Mount-WindowsImage -ImagePath "C:\DeploymentShare\Captures\WIN11-BASE.wim" -Path "C:\Mount" -Index 1

# Remove built-in apps
Get-AppxProvisionedPackage -Path "C:\Mount" | Where-Object {$_.DisplayName -like "*Xbox*" -or $_.DisplayName -like "*Zune*" -or $_.DisplayName -like "*Solitaire*"} | Remove-AppxProvisionedPackage

# Commit changes
Dismount-WindowsImage -Path "C:\Mount" -Save
```

## Base Image Contents

### Included
- Windows 11 Pro (latest cumulative update)
- .NET Framework 4.8
- Visual C++ Redistributables (2015-2022)
- Windows Terminal
- PowerShell 7
- Basic drivers

### Not Included (Added per-role)
- Development tools
- CAD software
- AI frameworks
- Docker Desktop
- Specialized drivers

## Next Steps

Use this base image with role-specific customization scripts:
- `Deploy-Melchior.ps1` for CAD workstation
- `Deploy-Balthazar.ps1` for AI host
- `Deploy-Caspar.ps1` for development machine