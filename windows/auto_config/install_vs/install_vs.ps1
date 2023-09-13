

if ( -Not ( Get-CimInstance MSFT_VSInstance -erroraction 'silentlycontinue' | findstr 'Visual Studio Community' ) ) {
    Write-Output "Visual Studio not installed! Installing.."
    
    # Download installer
    iwr https://aka.ms/vs/17/release/vs_community.exe -OutFile .\vs_community.exe
    
    # Install VS
    .\vs_community.exe                                  `
    --add Microsoft.VisualStudio.Workload.CoreEditor    `
    --add Microsoft.VisualStudio.Workload.Universal     `
    --add Microsoft.VisualStudio.Workload.NativeDesktop `
    --add Microsoft.VisualStudio.Workload.NativeGame    `
    --quiet --norestart
}
else {
    Write-Output "Visual studio installed already!"
}

# See all components: 
# https://learn.microsoft.com/en-us/visualstudio/install/workload-component-id-vs-community?view=vs-2022#components-included-by-this-workload-1