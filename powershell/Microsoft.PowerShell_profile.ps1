function Prompt {
	# redirects error to null
	# Gets the current branch which will contains '*' at the front
	$currentBranchExt = $((git branch) -match "\*");
	if ($currentBranchExt) {
		Try {
			# Holds the pattern for extracting the branch name
			$currentBranchMatchPattern = "\w*";
			# Executes the regular expression against the matched branch
			$currentBranchNameMatches = [regex]::matches($currentBranchExt, $currentBranchMatchPattern);
			# Gets the current branch from the matches
			$currentBranchName = $currentBranchNameMatches.Captures[2].Value.Trim();

			# Sets the Prompt which contains the Current git branch name
			# Prompt format - current_directory [ current_branch ] >
			"PS $($executionContext.SessionState.Path.CurrentLocation)$(' [ ' + $currentBranchName + ' ] >' * ($nestedPromptLevel + 1)) ";
		}
		Catch {
			# Calls the default prompt
			"PS $($executionContext.SessionState.Path.CurrentLocation)$('>' * ($nestedPromptLevel + 1)) ";
		}
	} else {
		# Calls the default prompt
		"PS $($executionContext.SessionState.Path.CurrentLocation)$('>' * ($nestedPromptLevel + 1)) ";
	}
}

function Make-Link ($target, $link) {
    New-Item -Path $link -ItemType SymbolicLink -Value $target
}

function fcat { python -m pygments -g $args }
function mntdeb { net use W: "\\wsl$\debian" }
function drives { gdr -PSProvider 'FileSystem' | Format-Wide -Property Root }

function which {
	if (Get-Alias -Name $args -ErrorAction SilentlyContinue) {
		Get-Alias -Name $args | Format-Wide -Property DisplayName -Auto
	} elseif (Get-Command $args -ErrorAction SilentlyContinue) {
		Get-Command $args | Format-Wide -Property Source -Auto
	} else {
		Write-Error -Message "Error: $args is not a command or alias" -Category InvalidArgument
	}
}
function search {
	gci -Recurse | sls -AllMatches -Pattern $args
}

New-Alias -Name jq -Value jq-win64
New-Alias -Name ln -Value Make-Link
New-Alias -Name pyi -Value "python -m ptpython"
New-Alias -Name vim -Value "C:\Program Files\Vim\vim91\vim.exe"
New-Alias -Name gvim -Value "C:\Program Files\Vim\vim91\gvim.exe"
