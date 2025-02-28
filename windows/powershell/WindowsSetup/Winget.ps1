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