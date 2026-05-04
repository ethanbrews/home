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
	#if ($LASTEXITCODE -gt 0) {
	#	$prompt += $PSStyle.Foreground.Red + $LASTEXITCODE + $PSStyle.Reset + "|"
	#}
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

Export-ModuleMember -Function Prompt
