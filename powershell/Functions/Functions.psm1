function New-Link {
    param(
        [Parameter(Mandatory, Position=0)][string]$Source,
        [Parameter(Mandatory, Position=1)][string]$Destination
    )
    New-Item -Path $Destination -ItemType SymbolicLink -Value $Source
}

function Show-Drives { Get-PSDrive -PSProvider 'FileSystem' | Format-Wide -Property Root }

function Show-Executable {
    if (Get-Alias -Name $args -ErrorAction SilentlyContinue) {
        Get-Alias -Name $args | Format-Wide -Property DisplayName -Auto
    } elseif (Get-Command $args -ErrorAction SilentlyContinue) {
        Get-Command $args | Format-Wide -Property Source -Auto
    } else {
        Write-Error -Message "Error: $args is not a command or alias" -Category InvalidArgument
    }
}
function Search-Recursive {
    Get-ChildItem -Recurse | Select-String -AllMatches -Pattern $args
}

function New-EmptyFile {
    param([Parameter(Mandatory, Position=0)][string]$Name)
    New-Item -Path . -Name $Name -ItemType "file"
}

function Get-ProcessForPort {
    param([Parameter(Mandatory, Position=0)][string]$Port)
    Get-Process -Id (Get-NetTCPConnection -LocalPort $Port).OwningProcess
}

function Get-CurrentlyAtRootDirectory {
    return (((Get-Location).Path) -match '^[a-zA-Z]:\\$')
}

function Move-UpDirectory {
    param(
        [Parameter(Position=0)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$Depth = 1
    )
    for ($i = 0; $i -lt $Depth; $i++) {
        if (Get-CurrentlyAtRootDirectory) {
            break
        }
        Set-Location '..'
    }
    if ($Depth -gt 1) {
        Get-Location | Format-Wide "Path"
    }
}

function Update-Profile {
    & $profile
}

function Update-AllWinGetPackages {
    $pkgs = Get-WinGetPackage | Where-Object -Property IsUpdateAvailable -eq $true
    Write-Host "$($pkgs.Count) packages available to upgrade."
    $pkgs | ForEach-Object { Update-WinGetPackage -Id $_.ID }
}

function Install-WinGetPackageInteractive {
    param(
        [Parameter(Mandatory, Position=0)][string]$Query
    )
    echo "Not implemented"
}

function Send-SshPublicKey {
    param(
        [Parameter(Mandatory, Position=0)][string]$User,
        [Parameter(Mandatory, Position=1)][string]$Hostname
    )

    Get-Content $env:userprofile/.ssh/id_rsa.pub | ssh "$User@$Hostname" 'cat >> .ssh/authorized_keys'
}

New-Alias -Name touch -Value New-EmptyFile
New-Alias -Name jq -Value jq-win64
New-Alias -Name ln -Value New-Link
New-Alias -Name vim -Value "nvim"
New-Alias -Name gvim -Value "nvim-qt"
New-Alias -Name which -Value Show-Executable
New-Alias -Name unzip -Value Expand-Archive
New-Alias -Name wgi -Value Install-WinGetPackage
New-Alias -Name wgs -Value Find-WinGetPackage
New-Alias -Name wgu -Value Update-WinGetPackage
New-Alias -Name '..' -Value Move-UpDirectory

Export-ModuleMember -Function New-Link,
                              Show-Drives,
                              Show-Executable,
                              Search-Recursive,
                              New-EmptyFile,
                              Get-ProcessForPort,
                              Move-UpDirectory,
                              Update-AllWinGetPackages,
                              Send-SshPublicKey

Export-ModuleMember -Alias touch,
                           jq,
                           ln,
                           vim,
                           gvim,
                           which,
                           unzip,
                           wgi,
                           wgs,
                           wgu,
                           '.. '
