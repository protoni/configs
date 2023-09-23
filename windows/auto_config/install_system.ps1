
# Check if run as admin and exit if not
If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')) {
    echo "Run as admin! Exiting.."
    exit
}

# Install fonts
echo "Installing fonts.."
cd install_fonts
& ".\install_fonts.ps1"
echo "Fonts installed!"
cd ..

# Install Dotnet Core
$choco_output = Get-Command -Name dotnet.exe -ErrorAction SilentlyContinue # Check if dotnet is installed
if (!$choco_output) {
    echo "Installing Dotnet Core.."
    & ".\dotnet/dotnet-install.ps1"
    echo "Dotnet Core installed!"
} else {
    echo "Dotnet Core installed already!"
}

# Install Windows Desktop Framework Packages
# $Folder = '%ProgramFiles(x86)%\Microsoft SDKs\Windows Kits\10\ExtensionSDKs\Microsoft.VCLibs.Desktop'
# $vclib_installed = Get-AppxPackage -AllUsers | Select Name, PackageFullName | findstr 'VCLibs'
# if($vclib_installed) {
if (Test-Path -Path 'C:\Program Files (x86)\Microsoft SDKs\Windows Kits\10\ExtensionSDKs\Microsoft.VCLibs.Desktop') {
    echo "Windows Desktop Framework Packages installed already!"
} else {
    echo "Installing Windows Desktop Framework Packages.."
    Add-AppxPackage 'vcLibs\Microsoft.VCLibs.x64.14.00.Desktop.appx'
}

# Enable Windows Store
Get-AppxPackage -allusers Microsoft.WindowsStore | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}

# Enable Hyper-V
$hyperv = Get-WindowsOptionalFeature -FeatureName Microsoft-Hyper-V-All -Online
if($hyperv.State -eq "Enabled") {
    echo "Hyper-V is enabled already!"
} else {
    echo "Hyper-V is disabled. Enabling.."
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
}

# Install chocolatey
$choco_output = Get-Command -Name choco.exe -ErrorAction SilentlyContinue # Check if chocolatey is installed
if (!$choco_output) {
    echo "Installing chocolatey.."
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    echo "Chocolatey installed!"
}

# Refresh environment variables
RefreshEnv.cmd

# Install Windows Terminal
$terminal_installed = choco list --localonly | findstr 'microsoft-windows-terminal' # Check if terminal is already installed
if(!$terminal_installed) {
    $choco_output = Get-Command -Name choco.exe -ErrorAction SilentlyContinue # Check if chocolatey is installed
    if($choco_output) {
        echo "Installing Windows Terminal.."
        choco install microsoft-windows-terminal -y
    } else {
        echo "Can't install Windows Terminal because Chocolatey is not installed!"
    }
} else {
    echo "Windows terminal installed already!"
}

# Install a program using Chocolatey
function install_program($name) {
    $program_installed = choco list --localonly | findstr /i $name # Check if the program is already installed
    if(!$program_installed) {
        $choco_output = Get-Command -Name choco.exe -ErrorAction SilentlyContinue # Check if chocolatey is installed
        if($choco_output) {
            echo "Installing $name.."
            choco install $name -y
        }
    } else {
        echo "$name installed already!"
    }
}

# Install Notepad++
install_program 'notepadplusplus'

# Setup Notepad++ settings and themes
if(-not(Test-Path -Path "..\..\notepadpp\INSTALLED_SETTINGS")) {
    echo "Setting up Notepad++.."
    [string]$sourceDirectory  = "..\..\notepadpp\*"
    # [string]$destinationDirectory = "%appdata%\notepad++\"
    [string]$destinationDirectory = "$Env:USERPROFILE\AppData\Roaming\Notepad++"
    Copy-item -Force -Recurse $sourceDirectory -Destination $destinationDirectory
    New-Item -Path ..\..\notepadpp\ -Name "INSTALLED_SETTINGS" -ItemType "file" -Value ""
} else {
    echo "Notepad++ has been setup already!"
}

# Install Virtualbox
install_program 'virtualbox'

# Install Windows subsystem for Linux ( WSL )
$wsl_installed = wsl -l |Where {$_.Replace("`0","") -match '^Ubuntu'}
if(!$wsl_installed) {
    echo "Installing WSL Ubuntu 20.04.."
    wsl --install -d Ubuntu-20.04
} else {
    echo "WSL Ubuntu installed already!"
}

# Install Nodejs
install_program 'nodejs'

# Install Git
install_program 'git'

# Install Git LFS
install_program 'git-lfs'

# Install OpenSSL
install_program 'openssl'

# Install Keepass
install_program 'keepass'

# Install Firefox
install_program 'firefox'

# Install Visual studio
echo "Installing Visual Studio.."
cd install_vs
& ".\install_vs.ps1"
echo "Visual Studio installed!"
cd ..

# Install Docker
echo "Installing Docker.."
cd install_docker
& ".\install_docker.ps1"
echo "Docker installed!"
cd ..

# Install VMs
echo "Installing Virtual machines.."
cd install_vm
& ".\install-ubuntu-vm.ps1"
& ".\install-win10-vm.ps1"
echo "Virtual machines installed!"
cd ..

# Check that python is installed
function check_python {
    $installed = $FALSE
    
    $python_version = python.exe --version
    if($python_version) {
        $python_version = $python_version.split('.').split(' ')
        
        if ([int]$python_version[1] -ge 3) {
            $installed = $TRUE
        }
    }
    
    return $installed
}

# Install python
$python_installed = check_python
if(!$python_installed) {
    echo "Installing python.."
    choco install python --version=3.9.0 -y
    
    if(Test-Path -Path 'C:\Python39') {
        echo "Adding python to Path.."
        $env:Path += ';C:\Python39'
    } else {
        echo "Error! Can't add python to path because the folder is missing."
    }
}

# Refresh environment variables
RefreshEnv.cmd

# Assign machine path to system path
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine")

# Change Windows Terminal settings if python is installed
$scriptBlock = {
    python.exe 'change_terminal_settings\change_terminal_settings.py'
}
echo "Changing Windows Terminal Settings.."
# & ".\change_terminal_settings/change_settings.ps1"
# Start-Process powershell  -ArgumentList ("-ExecutionPolicy Bypass -noninteractive -noprofile " + $scriptBlock) -PassThru
powershell.exe -command $scriptBlock



## Misc

# Show file extensions in folders
$files_hidden = (Get-ItemProperty Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name HideFileExt).HideFileExt
if([int]$files_hidden -ne 0) {
    echo "Modifying registry to enable file extensions in folders.."
    reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v HideFileExt /t REG_DWORD /d 0 /f
    
    # Restart UI
    Stop-Process -processName: Explorer -force
} else {
    echo "Already showing file extensions!"
}


# Turn off telemetry and diagnostics data collecting services
echo "Turning off telemetry and diagnostics data collection.."
sc delete DiagTrack
sc delete dmwappushservice
echo "" > C:\\ProgramData\\Microsoft\\Diagnosis\\ETLLogs\\AutoLogger\\AutoLogger-Diagtrack-Listener.etl
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f
Disable-ScheduledTask -TaskName "Microsoft Compatibility Appraiser" -TaskPath "\Microsoft\Windows\Application Experience"

# Delete bloatware apps
#echo "Deleting bloatware applications.."
#& ".\delete_bloatware/delete_bloatware.ps1"
#echo "Bloatware deleted!"

# Disable unnecessary scheduled tasks and services
echo "Disabling unnecessary tasks.."
& ".\disable_tasks/disable_tasks.ps1"
echo "Unnecessary tasks disabled!"

# Cleanup start menu
echo "Cleaning up start menu.."
cd cleanup_startupmenu
& ".\cleanup_startupmenu.ps1"
echo "Start menu cleaned up!"
cd ..


## Windows Updates

# Install Windows Updater module if not installed already
$module_output = Get-Module -ListAvailable -Name PSWindowsUpdate
if(!$module_output) {
    echo "Installing Windows Updater module.."
    Install-Module PSWindowsUpdate -Confirm:$false
}

# Get new Windows updates
$updates_available = Get-WindowsUpdate
if($updates_available) {
    echo "Installing Windows updates.."
    Install-WindowsUpdate -Confirm:$false
} else {
    echo "No Windows updates available!"
    
}

# Install registry hacks
echo "Installing registry hacks.."
& ".\misc_registry_edits.ps1"
echo "Registry hacks installed!"

