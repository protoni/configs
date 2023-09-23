# Define VM parameters
$vmName = "Ubuntu22-04"
$osType = "Linux"
$memoryMB = 2048
$diskSizeMB = 20000

# Check if the vm already exists
if (VBoxManage list vms | findstr $vmName) {
    Write-Host "$vmName VM exists already! Exiting.."
    exit
}

$isoFile = "Ubuntu-22-04.iso"

# Disable progress bar, which slows down the download for some reason
$ProgressPreference = 'SilentlyContinue'

# Download the Ubuntu Desktop ISO
Invoke-WebRequest -Uri "https://releases.ubuntu.com/22.04/ubuntu-22.04.3-desktop-amd64.iso" -OutFile $isoFile

Write-Host "Ubuntu 22.04 Desktop ISO downloaded to $isoFile"

# Create the VM
VBoxManage createvm --name $vmName --ostype $osType --register

# Configure VM settings
VBoxManage modifyvm $vmName --memory $memoryMB
VBoxManage createhd --filename "$vmName.vdi" --size $diskSizeMB
VBoxManage storagectl $vmName --name "SATA Controller" --add sata --controller IntelAHCI
VBoxManage storageattach $vmName --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "$vmName.vdi"
VBoxManage storageattach $vmName --storagectl "SATA Controller" --port 1 --device 0 --type dvddrive --medium $isoFile

# Start the VM
#VBoxManage startvm $vmName

# Cleanup
del $isoFile