Import-Module MultiSelect


function Invoke-QuickSwitchMenu {
    [CmdletBinding()]
    param (
        [Parameter(ParameterSetName='SingleFolderSet', Mandatory=$true)]
        [string]$Folder,

        [Parameter(ParameterSetName='MultiFolderSet', Mandatory=$true)]
        [string[]]$Folders
    )

    $Items = $null

    switch ($PSCmdlet.ParameterSetName) {
       'SingleFolderSet' {
            $Items = Get-ChildItem -Path $Folder -Directory -Force -ErrorAction SilentlyContinue | Select-Object FullName
        }
        'MultiFolderSet' {
            Write-Host $Folders
            $Items = $Folders | % { Get-Item -Path $_ | Select-Object FullName }
        }
    }
    
    Invoke-QuickSelectMenu -Title 'Quick Switch' -Items $Items
}

function Invoke-QuickSelectMenu {
    [CmdletBinding()]
    param(
        [Parameter(ParameterSetName='RawTextSet', Mandatory=$true, ValueFromPipelineByPropertyName=$true, ValueFromPipeline=$true)]
        [string]$RawString,

        [Parameter(ParameterSetName='RawTextSet', Mandatory=$false)]
        [string]$Delimeter = $([System.Environment]::NewLine),

        [Parameter(ParameterSetName='ArraySet', Mandatory=$true)]
        [string[]]$Items,

        [Parameter()]
        [string]$Title = 'Select'
    )

    switch ($PSCmdlet.ParameterSetName) {
       'RawTextSet' {
           $Items = $RawString -Split $Delimeter
        }
        'ArraySet' { }
    }

    $res = Write-Menu -Title $Title -Entries [object[]]$Items
    return $res
}
