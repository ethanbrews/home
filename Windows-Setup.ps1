param(
    [switch]$InstallWinget,
    [string[]]$InstallPackages
)

Add-Type -AssemblyName System.Windows.Forms

function Ask-Question {
    param(
        [string]$Title,
        [string]$Message = "",
        [bool]$Default,
        [string]$Yes = "Continue with installation",
        [string]$No = "Skip this stage"
    )

    $choices = @(
        [System.Management.Automation.Host.ChoiceDescription]::new("&Yes", "$Yes")
        [System.Management.Automation.Host.ChoiceDescription]::new("&No", "$No")
        [System.Management.Automation.Host.ChoiceDescription]::new("&Abort", "Abort installation and exit immediately")
    )

    $defaultIndex = 1
    if ($Default) {
        $defaultIndex = 0
    }

    $result = $host.ui.PromptForChoice($Title, $Message, $choices, $defaultIndex)

    if ($result -eq 2) {
        exit 1
    }
    return $result -eq 0
}

function Is-RunningAsAdmin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Install-WinGet {
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

$isDotSourced = $MyInvocation.InvocationName -eq '.' -or $MyInvocation.Line -eq ''
if ($isDotSourced) {
    exit 0
}

if ($InstallWinGet -or (Ask-Question -Title "Install WinGet" -Message "Install the latest WinGet package?" -Default $false)) {
    Write-Host "Installing WinGet"
    Install-WinGet
}


