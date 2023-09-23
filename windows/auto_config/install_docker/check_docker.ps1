# Check if Docker Desktop is already installed
if (-not (Get-Command -Name docker -ErrorAction SilentlyContinue)) {
    # Download the Docker Desktop installer
    $dockerInstallerUrl = "https://desktop.docker.com/win/stable/Docker%20Desktop%20Installer.exe"
    $dockerInstallerPath = Join-Path $env:TEMP "DockerDesktopInstaller.exe"
    #Invoke-WebRequest -Uri $dockerInstallerUrl -OutFile $dockerInstallerPath

    # Install Docker Desktop
    Start-Process -FilePath $dockerInstallerPath -Wait
    Remove-Item -Path $dockerInstallerPath -Force

    # Wait for Docker to start
    Start-Sleep -Seconds 15

    # Check if Docker is running
    if (Get-Service -Name "com.docker.service" -ErrorAction SilentlyContinue) {
        Write-Host "Docker Desktop is installed and running."
    } else {
        Write-Host "Docker Desktop installation failed."
    }
} else {
    Write-Host "Docker Desktop is already installed."
}