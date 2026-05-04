function Get-AvailableWindowsFeatures {
    return @(
        "Microsoft-Hyper-V-All",
        "Printing-PrintToPDFServices-Features",
        "TelnetClient",
        "VirtualMachinePlatform",
        "HypervisorPlatform",
        "Containers-DisposableClientVM", # Sandbox
        "Microsoft-Windows-Subsystem-Linux"
    )
}

function Is-FeatureEnabled {
    param(
        [Parameter(Mandatory, position=0)]
        [string]$Feature
    )
    $feature = Get-WindowsOptionalFeature -Online -FeatureName $Feature

    return ($feature.State -eq "Enabled")
}

function Is-FeatureAvailable {
    param(
        [Parameter(Mandatory, position=0)]
        [string]$Feature
    )
    $feature = Get-WindowsOptionalFeature -Online -FeatureName $Feature

    return (($feature.State -eq "Enabled") -or ($feature.State -eq "Disabled"))
}

function Enable-Features {
    param(
        [Parameter(Mandatory, position=0)]
        [string[]]$Features
    )
    foreach ($feature in $Features) {
        Enable-WindowsOptionalFeature -Online -FeatureName $feature -NoRestart
    }
}