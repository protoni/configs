$bloatware = DISM /Online /Get-ProvisionedAppxPackages | select-string Packagename

$excluded = @('MSPaint','Office','VCLibs', 'Realtek')

function is_excluded() {
    For ($x=0; $x -lt $excluded.Length; $x++) {
        if($tmp[1].Contains($excluded[$x])) {
            return $TRUE
        }
    }
    
    return $FALSE
}

For ($i=0; $i -lt $bloatware.Length; $i++) {
    $tmp = $bloatware[$i].ToString()
    $tmp = $tmp.split(':')
    $tmp[1] = $tmp[1] -replace '\s',''
    $tmp[1] = $tmp[1] -replace '\n',''
    $tmp[1] = $tmp[1] -replace '\r',''
    $tmp[1] = $tmp[1] -replace '\r\n',''

    # Check if app includes excluded words and discard deletion
    $to_save = is_excluded($tmp[1])
    if(!$to_save) {
        echo "Deleting application: "$tmp[1]
        Remove-AppxProvisionedPackage -Online -PackageName $tmp[1]
    }
    
}

echo "Applications excuded from deletion in bloatware list:"
DISM /Online /Get-ProvisionedAppxPackages | select-string Packagename