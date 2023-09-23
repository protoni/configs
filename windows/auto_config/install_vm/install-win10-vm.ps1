$vmName = "Win10"
$pathPrefix = "win_vm"

# Check if win10 vm already exists
if (Get-VM -Name $vmName -ErrorAction SilentlyContinue) {
    Write-Host "$vmName VM exists already! Exiting.."
    exit
}

# Enable Hyper-V
$hyperv = Get-WindowsOptionalFeature -FeatureName Microsoft-Hyper-V-All -Online
if($hyperv.State -eq "Enabled") {
    echo "Hyper-V is enabled already!"
} else {
    echo "Hyper-V is disabled. Enabling.."
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
}

# Create VM
New-VM -Name $vmName -MemoryStartupBytes 2048MB -Path .\$pathPrefix.local
New-VHD -Path .\$pathPrefix.local.vhdx -SizeBytes 20GB -Dynamic
Add-VMHardDiskDrive -VMName $vmName -Path .\$pathPrefix.local.vhdx

# Download Windows 10 .iso
git clone https://github.com/pbatard/Fido.git
Fido\Fido.ps1 -Win 10 -Ed Pro

# Add windows .iso
$winIso = Get-ChildItem -Path . -Recurse -Filter "Win10_*.iso"
Set-VMDvdDrive -VMName $vmName -ControllerNumber 1 -Path $winIso

# Enable dynamic memory allocation
Set-VMMemory -VMName $vmName -DynamicMemoryEnabled $true -StartupBytes 2048MB -MinimumBytes 2048MB

# Start VM
#Start-VM -Name $vmName

# Start GUI
#vmconnect.exe localhost $vmName

# Cleanup
del $winIso
del Fido