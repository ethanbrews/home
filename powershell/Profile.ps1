function Get-GitBranch {
	try {
		$branch = git rev-parse --abbrev-ref HEAD 2> $null
		return $branch.Trim()
	} catch {
		return ""
	}
}

function Prompt {
	$prompt = ""
	if ($LASTEXITCODE -gt 0) {
		$prompt += $PSStyle.Foreground.Red + $LASTEXITCODE + $PSStyle.Reset + "|"
	}
	$prompt += $PSStyle.Foreground.Blue + "[" + $PSStyle.Reset
	$prompt += $(Get-Date -Format "HH:mm:ss")
	$prompt += " " + $PSStyle.Foreground.Blue + $(Resolve-Path .).Path.Replace($(Resolve-Path "~").Path, '~') + $PSStyle.Reset

	$gitBranch = Get-GitBranch
	if ($gitBranch -ne "") {
		$prompt += " " + $PSStyle.Foreground.Yellow + "(" + $gitBranch + ")" + $PSStyle.Reset
	}
	$prompt += $PSStyle.Foreground.Blue + "]" + $PSStyle.Reset + "$ "
	return $prompt
}

function Make-Link {
	param(
		[string]$Source,
		[string]$Destination
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

function Create-EmptyFile($file) {
    "" | Out-File $file -Encoding ASCII
}

$PSStyle.FileInfo.Directory = $PSStyle.Foreground.Blue

New-Alias -Name jq -Value jq-win64
New-Alias -Name ln -Value Make-Link
New-Alias -Name vim -Value "nvim"
New-Alias -Name which -Value Show-Executable
New-Alias -Name touch -Value Create-EmptyFile
New-Alias -Name .. -Value "cd .."
