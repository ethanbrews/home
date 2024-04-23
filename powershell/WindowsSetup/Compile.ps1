param(
    [string]$Script,
    [string]$OutFile
)

# Get the directory of the script
$scriptDirectory = Split-Path -Parent $Script

# Read the content of the script
$scriptContent = Get-Content -Path $Script

# Iterate through each line of the script
$newScriptContent = foreach ($line in $scriptContent) {
    # Check if the line matches the pattern ". .\script.ps1"
    if ($line -match '^\.\s*\.\s*(?<ScriptPath>.+\.ps1)$') {
        # Extract the script path from the line
        $referencedScriptPath = Join-Path -Path $scriptDirectory -ChildPath $matches['ScriptPath']

        # Read the content of the referenced script
        $referencedScriptContent = Get-Content -Path $referencedScriptPath

        # Output the content of the referenced script
        foreach ($referencedLine in $referencedScriptContent) {
            Write-Output $referencedLine
        }
    } else {
        # Output the original line if it doesn't match the pattern
        Write-Output $line
    }
}

# Write the modified script content back to the original script file
$newScriptContent | Set-Content -Path $OutFile
