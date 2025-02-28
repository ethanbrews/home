. .\Admin.ps1
Restart-ScriptAsAdmin -Invocation $MyInvocation
. .\Winget.ps1
. .\Features.ps1

Write-Host "Upgrading WinGet"
Upgrade-WinGet

Write-Host "Installing Packages"
@(
    # "Microsoft.Office"
) | ForEach {
    Install-Package -Id $_
}

Write-Host "Enabling optional features"
$desiredFeatures = @("Printing-PrintToPDFServices-Features", "Microsoft-Hyper-V-All")
$toEnable = $desiredFeatures | Where-Object { Is-FeatureAvailable $_ } | Where-Object { -not (Is-FeatureEnabled $_) }
if ($toEnable) {
    Enable-Features $toEnable
}

Write-Host "Setting display and system sleep settings: Never"
# Set turn off display time to "Never" for both plugged in and unplugged
powercfg /SETACVALUEINDEX SCHEME_CURRENT SUB_VIDEO VIDEOIDLE 0
powercfg /SETDCVALUEINDEX SCHEME_CURRENT SUB_VIDEO VIDEOIDLE 0

# Set sleep timer to "Never" for both plugged in and unplugged
powercfg /SETACVALUEINDEX SCHEME_CURRENT SUB_SLEEP STANDBYIDLE 0
powercfg /SETDCVALUEINDEX SCHEME_CURRENT SUB_SLEEP STANDBYIDLE 0
powercfg /SETACVALUEINDEX SCHEME_CURRENT SUB_SLEEP HIBERNATEIDLE 0
powercfg /SETDCVALUEINDEX SCHEME_CURRENT SUB_SLEEP HIBERNATEIDLE 0


Start-Sleep -Seconds 10