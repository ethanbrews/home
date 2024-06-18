$homePath = (Get-Item $PSScriptRoot).parent.FullName
$env:PSModulePath += ";$homePath"

Import-Module Prompt
Import-Module Functions
Import-Module Styles
Import-Module Admin
Import-Module QuickSwitch
Import-Module Aliases
