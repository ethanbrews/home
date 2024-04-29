function Test-Administrator  {  
	$user = [Security.Principal.WindowsIdentity]::GetCurrent();
	(New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)  
}

function Invoke-AsAdmin {
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

Export-ModuleMember -Function Test-Administrator, Invoke-AsAdmin
