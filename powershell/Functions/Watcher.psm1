function Get-FolderInListByName {
    param (
        [Parameter(Mandatory)]
        [string]$FolderName,

        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [array]$FoldersList
    )
    
    foreach ($folder in $FoldersList) {
        if ($folder.Folder -eq $FolderName) {
            return $folder
        }
    }

    return $null
}

function Test-FolderInList {
     param (
        [Parameter(Mandatory)]
        [string]$FolderName,

        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [array]$FoldersList
    )
    return $null -ne (Get-FolderInListByName -FolderName $FolderName -FoldersList $FoldersList)
}

function Convert-ToFolderStructure {
    param (
        [Parameter(Mandatory)][string[]]$Paths
    )
    $folders = @()

    foreach ($filePath in $Paths) {
        $folder = $null
        if (Test-Path -Path $filePath -PathType Leaf) {
            $folder = Split-Path -Path $filePath -Parent
        } else {
            $folder = $filePath
        }

        # Add the folder to the list if it's not already in the list
        if ($folder -ne "" -and (-not (Test-FolderInList -FolderName $folder -FoldersList $folders))) {
            $folders += @{
                Folder = $folder
                Recursive = $false
                Files = @()
            }
        }
        if ($folder -eq $filePath) {
            (Get-FolderInListByName -FoldersList $folders -FolderName $folder).Recursive = $true
        }
    }

    return $folders
}


function Watch-ForFileChanges {
    param(
        [Parameter(Mandatory, Position=0)][string[]]$Files,
        [Parameter(Mandatory, Position=1)][scriptblock]$Action
    )

    $Paths = $Files | ForEach-Object { (Resolve-Path $_).Path }
    Write-Host $Paths
    $folders = Convert-ToFolderStructure -Paths $Paths

    $watchers = @()

    foreach($folder in $folders) {
        $watcher = New-Object System.IO.FileSystemWatcher
        $watcher.Path = $folder.Folder
        $watcher.IncludeSubdirectories = $folder.Recursive
        $watcher.EnableRaisingEvents = $true
        $data = @{
            Paths = $Paths
            Recursive = $folder.Recursive
            Action = $Action
        }
        Register-ObjectEvent -InputObject $watcher -EventName Changed -MessageData $data -Action {
            $e = $event.SourceEventArgs
            $changedFile = $e.FullPath
            $recursive = $event.MessageData.Recursive
            $paths = $event.MessageData.
            $action = $event.MessageData.Action
            Write-Host $lock
            if ($recursive -or ($paths -contains $changedFile)) {
                Invoke-Command -ScriptBlock $action
            }
        } | Out-Null
        $watchers += $watcher
    }

    Write-Host "File system watcher is running. Press Ctrl+C to stop."
    try {
        Wait-Event -Timeout ([System.Threading.Timeout]::Infinite)
    } finally {
        foreach($watcher in $watchers) {
            $watcher.Dispose()
        }
    }
}
