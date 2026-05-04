function Is-RunningAsAdmin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Restart-ScriptAsAdmin {
    param(
        [Parameter(Mandatory)][System.Management.Automation.InvocationInfo]$Invocation,
        [switch]$NoExit
    )
    if (Is-RunningAsAdmin) { return }
    $CmdLine = "cd $PWD; & `"" + $Invocation.MyCommand.Path + "`" " + $Invocation.UnboundArguments
    if (-not $NoExit) {
        $CmdLine += "; exit"
    }
    Write-Information "Running '$CmdLine' in elevated prompt."
    Start-Process powershell.exe -verb runAs -ArgumentList '-NoExit', '-Command', "$CmdLine"
    Exit
}

function Run-AsAdmin {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, position=0)]
        [scriptblock]$ScriptBlock,
        [switch]$NoExit
    )

    # Convert the script block to a string
    $scriptBlockString = "$ScriptBlock"
    if (-not $NoExit) {
        $scriptBlockString += "; exit"
    }

    # Start an elevated PowerShell process with the script block as a command-line argument
    $process = Start-Process -FilePath powershell.exe -ArgumentList "-NoProfile -NoExit -Command `"$scriptBlockString`"" -Verb RunAs -PassThru

    if ($process) {
        # Wait for the process to start
        while (-not (Get-Process -Id $process.Id -ErrorAction SilentlyContinue)) {
            Start-Sleep -Milliseconds 100  # Wait 0.1 second before checking again
        }
    } else {
        Write-Error "Failed to start an elevated PowerShell process."
    }
}
Restart-ScriptAsAdmin -Invocation $MyInvocation
function _Install-WinGet {
    Write-Information "Installing WinGet from package."
    $tempFolderPath = [System.IO.Path]::GetTempPath()
    $progressPreference = 'silentlyContinue'
    $latestWingetMsixBundleUri = $(Invoke-RestMethod "https://api.github.com/repos/microsoft/winget-cli/releases/latest").assets.browser_download_url | Where-Object {$_.EndsWith(".msixbundle")}
    $latestWingetMsixBundle = $latestWingetMsixBundleUri.Split("/")[-1]
    $latestWingetMsixBundlePath = Join-Path -Path $tempFolderPath -ChildPath $latestWingetMsixBundle
    $vcLibsFile = Join-Path -Path $tempFolderPath -ChildPath "Microsoft.VCLibs.x64.14.00.Desktop.appx"

    Write-Information "Downloading winget to artifacts directory..."
    Invoke-WebRequest -Uri $latestWingetMsixBundleUri -OutFile $latestWingetMsixBundlePath
    Invoke-WebRequest -Uri "https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx" -OutFile $vcLibsFile

    $FileVersion = (Get-ItemProperty -Path $vcLibsFile).VersionInfo.ProductVersion
    $HighestInstalledVersion = Get-AppxPackage -Name Microsoft.VCLibs* |
        Sort-Object -Property Version |
        Select-Object -ExpandProperty Version -Last 1
    if ( $HighestInstalledVersion -lt $FileVersion ) {
        Add-AppxPackage $vcLibsFile
    }
    Add-AppxPackage $latestWingetMsixBundlePath
}

function Install-WinGetPackage {
    param([string]$Id)
    Invoke-Expression -Command "winget install --exact --id $Id"
}

function Upgrade-WinGet {
    [CmdletBinding()]
    param(
        [switch]$UpgradeOnly,
        [switch]$InstallFromPackage
    )

    if ($UpgradeOnly -and $InstallFromPackage) {
        throw "UpgradeOnly and InstallFromPackage cannot be set simultaneously."
    }

    # Check winget is installed by running winget --version and then try to install or upgrade accordingly
    $WingetVersionSuccess = $(Invoke-Expression -Command "winget --version"; $?)
    if ($InstallFromPackage -or (-not $WingetVersionSuccess)) {
        if ($UpgradeOnly) {
            Write-Information "WinGet is not installed but -UpgradeOnly was set."
            return
        }
        Install-WinGet
    } else {
        $UpgradeSuccess = $(Invoke-Expression -Command "winget upgrade Microsoft.AppInstaller"; $?)
        if ($UpgradeSuccess -or $UpgradeOnly) { return }
        # If the upgrade fails, assume WinGet is too outdated to upgrade itself and install from package.
        Install-WinGet
    }

    # Finally, use winget to upgrade itself to the most recent version
    Invoke-Expression -Command "winget upgrade Microsoft.AppInstaller"
}
function Get-AvailableWindowsFeatures {
    return @(
        "Microsoft-Hyper-V-All",
        "Printing-PrintToPDFServices-Features",
        "TelnetClient",
        "VirtualMachinePlatform",
        "HypervisorPlatform",
        "Containers-DisposableClientVM", # Sandbox
        "Microsoft-Windows-Subsystem-Linux"
    )
}

function Is-FeatureEnabled {
    param(
        [Parameter(Mandatory, position=0)]
        [string]$Feature
    )
    $feature = Get-WindowsOptionalFeature -Online -FeatureName $Feature

    return ($feature.State -eq "Enabled")
}

function Is-FeatureAvailable {
    param(
        [Parameter(Mandatory, position=0)]
        [string]$Feature
    )
    $feature = Get-WindowsOptionalFeature -Online -FeatureName $Feature

    return (($feature.State -eq "Enabled") -or ($feature.State -eq "Disabled"))
}

function Enable-Features {
    param(
        [Parameter(Mandatory, position=0)]
        [string[]]$Features
    )
    foreach ($feature in $Features) {
        Enable-WindowsOptionalFeature -Online -FeatureName $feature -NoRestart
    }
}

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
