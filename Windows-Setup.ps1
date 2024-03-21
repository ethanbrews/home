param(
    [switch]$InstallWinget,
    [switch]$NoConfirm
)

Add-Type -AssemblyName System.Windows.Forms

function Ask-Question {
    param(
        [string]$Title,
        [string]$Message = "",
        [bool]$Default,
        [string]$Yes = "Yes",
        [string]$No = "No"
    )

    if ($NoConfirm) {
        return $Default
    }

    $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes",$Yes
    $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No",$No
    $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)

    $defaultIndex = 0
    if ($Default) {
        $defaultIndex = 1
    }

    return $host.ui.PromptForChoice($Title, $Message, $options, $defaultIndex)
}

function Is-RunningAsAdmin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Install-WinGet {
    $progressPreference = 'silentlyContinue'
    $latestWingetMsixBundleUri = $(Invoke-RestMethod "https://api.github.com/repos/microsoft/winget-cli/releases/latest").assets.browser_download_url | Where-Object {$_.EndsWith(".msixbundle")}
    $latestWingetMsixBundle = $latestWingetMsixBundleUri.Split("/")[-1]
    Write-Information "Downloading winget to artifacts directory..."
    Invoke-WebRequest -Uri $latestWingetMsixBundleUri -OutFile "./$latestWingetMsixBundle"
    Invoke-WebRequest -Uri "https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx" -OutFile "Microsoft.VCLibs.x64.14.00.Desktop.appx"
    # Only install VCLibs if it needs to be installed/upgraded
    $FilePath = ".\Microsoft.VCLibs.x86.14.00.appx"
    $FileVersion = (Get-ItemProperty -Path $FilePath).VersionInfo.ProductVersion
    $HighestInstalledVersion = Get-AppxPackage -Name Microsoft.VCLibs* |
        Sort-Object -Property Version |
        Select-Object -ExpandProperty Version -Last 1
    if ( $HighestInstalledVersion -lt $FileVersion ) {
        Add-AppxPackage $FilePath
    }

    Add-AppxPackage $latestWingetMsixBundle
}

function Enable-AutomaticLogon {
    param(
        [string]$UserName = $env:UserName,
        [string]$Domain,
        [Parameter(Mandatory=$true)]
        [SecureString]$Password
    )
    $userSID = (Get-WmiObject -Class Win32_UserAccount | Where-Object { $_.Name -eq $UserName }).SID
    Write-Information "Enabling automatic signin"
    # Automatic sign-in is just a few registry keys...
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "AutoAdminLogon" -Value "1"
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "DefaultUserName" -Value $UserName
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "DefaultPassword" -Value $Password
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "AutoLogonSID" -Value $userSID
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "dontdisplaylastusername" -Value "1"
    if ($Domain -ne $null) {
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "DefaultDomainName" -Value $Domain
    }
}