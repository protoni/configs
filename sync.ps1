
# Notepad configs to sync to/from
$notepad_conf_root = "$Env:USERPROFILE\AppData\Roaming\Notepad++\"
$notepad_conf_paths = @("plugins\config\converter.ini",
                        "themes\custom_theme.xml",
                        "shortcuts.xml",
                        "stylers.xml")
$notepad_conf_root_git = ".\notepadpp\"

# VSCode configs to sync to/from
$vscode_conf_root = "$Env:USERPROFILE\AppData\Roaming\Code\User\"
$vscode_conf_paths = @("keybindings.json",
                       "settings.json")
$vscode_conf_root_git = ".\vscode\"

function CreateBackup {
    param (
        $path_name
    )
    
    # Create a backup folder
    $backup_folder = $path_name.TrimEnd('\') + "_backup\"

    # Copy all configs under backup folder
    if (Test-Path -Path $backup_folder) { Remove-Item -Path $backup_folder -Recurse }
    Copy-Item -Path $path_name -Destination $backup_folder -Recurse

}

function Backup() {
    CreateBackup $notepad_conf_root
    CreateBackup $vscode_conf_root
    CreateBackup $notepad_conf_root_git
    CreateBackup $vscode_conf_root_git
}

function Analyze() {
    param (
        $path,
        $git_path,
        $files
    )

    for($i=0; $i -lt $files.Length; $i++) { 
        $in_use_conf = $path + $files[$i]
        $git_conf = $git_path + $files[$i]

        $objects = @{
            ReferenceObject = (Get-Content -Path $in_use_conf)
            DifferenceObject = (Get-Content -Path $git_conf)
          }
          $out = Compare-Object @objects -PassThru

          if ($out.Length -gt 0) {
            $changes = ( $out.Length - 1 ) / 2
            echo "$in_use_conf has changed with $changes differences"
          }
    }
}

function CopyItem {
    param (
        $to,
        $from
    )
    
    Copy-Item -Path $from -Destination $to -Recurse
}

function CopyAll {
    param (
        $to,
        $from,
        $files
    )
    
    for($i=0; $i -lt $files.Length; $i++) {
        $destination = $to + $files[$i]
        $source = $from + $files[$i]
        CopyItem $source $destination
    }
}

echo "Sync tool"
echo "Usage: "
echo "    1: Analyze differences"
echo "    2: Copy to saved settings ( system paths -> this repo )"
echo "    3: Copy from saved settings ( this repo -> system paths )"
$answer = Read-Host ">"
if($answer -eq 1) {
    echo "Analyze differences"
    Analyze $notepad_conf_root $notepad_conf_root_git $notepad_conf_paths
    Analyze $vscode_conf_root $vscode_conf_root_git $vscode_conf_paths
}
elseif($answer -eq 2) {
    echo "Copy to saved settings"
    Backup
    CopyAll $notepad_conf_root $notepad_conf_root_git $notepad_conf_paths
}
elseif($answer -eq 3) {
    echo "Copy from saved settings"
    Backup
    CopyAll $notepad_conf_root_git $notepad_conf_root $notepad_conf_paths
}
else {
    echo "Invalid response"
}