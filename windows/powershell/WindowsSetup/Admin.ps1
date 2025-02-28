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
