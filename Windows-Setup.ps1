param(
    [switch]$InstallWinget,
    [switch]$InstallPackages,
    [switch]$InstallFonts,
    [switch]$All
)

Add-Type -AssemblyName System.Windows.Forms

function Ask-Question {
    param(
        [string]$Title,
        [string]$Message = "",
        [bool]$Default,
        [string]$YesDescription = "Continue with installation",
        [string]$NoDescription = "Skip this stage",
        [string]$Yes = "Yes",
        [string]$No = "No", 
        [bool]$CanAbort = $true,
        [switch]$RequiresInput
    )

    if ($All -and (-not $RequiresInput)) {
        Write-Host "$Title"
        Write-Host "$Message"
        Write-Host (if ($Default) { $Yes } else { $No })
        return $Default
    }

    $choices = @(
        [System.Management.Automation.Host.ChoiceDescription]::new("&$Yes", "$YesDescription")
        [System.Management.Automation.Host.ChoiceDescription]::new("&$No", "$NoDescription")
    )
    if ($CanAbort) {
        $choices += [System.Management.Automation.Host.ChoiceDescription]::new("&Abort", "Abort installation and exit immediately")
    }
    $defaultIndex = 1
    if ($Default) {
        $defaultIndex = 0
    }

    $result = $host.ui.PromptForChoice($Title, $Message, $choices, $defaultIndex)

    if ($result -eq 2) {
        exit 1
    }
    return $result -eq 0
}

function Add-Font {
    param(
        [System.IO.FileSystemInfo]$File
    )
    $Destination = (New-Object -ComObject Shell.Application).Namespace(0x14)
    If (-not(Test-Path "C:\Windows\Fonts\$($File.Name)")) {
        Write-Information "Installing $($File.Name)"
        $Destination.CopyHere($File,0x10)
    }
}

function Show-MultiSelectMenu {
    param (
        [string[]]$Options
    )

    $title = "Select options"
    $message = "Use arrow keys to navigate, space to select/deselect, and Enter to confirm."
    $choices = @()
    
    foreach ($option in $Options) {
        $choices += New-Object System.Management.Automation.Host.ChoiceDescription "&$option", $option
    }

    $selectedIndices = @()

    while ($true) {
        $selectedIndex = $Host.UI.PromptForChoice($title, $message, $choices, 0)

        if ($selectedIndices -contains $selectedIndex) {
            $selectedIndices = $selectedIndices | Where-Object { $_ -ne $selectedIndex }
        } else {
            $selectedIndices += $selectedIndex
        }
        
        # Check if the user pressed Enter to exit
        if ($Host.UI.RawUI.KeyAvailable) {
            $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            if ($key.VirtualKeyCode -eq 13) {
                break
            }
        }
    }

    # Convert selected indices to options and return
    $selectedOptions = $selectedIndices | ForEach-Object { $Options[$_] }
    return $selectedOptions
}

function Is-RunningAsAdmin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Install-WinGet {
    $tempFolderPath = [System.IO.Path]::GetTempPath()
    $progressPreference = 'silentlyContinue'
    $latestWingetMsixBundleUri = $(Invoke-RestMethod "https://api.github.com/repos/microsoft/winget-cli/releases/latest").assets.browser_download_url | Where-Object {$_.EndsWith(".msixbundle")}
    $latestWingetMsixBundle = $latestWingetMsixBundleUri.Split("/")[-1]
    $latestWingetMsixBundlePath = Join-Path -Path $tempFolderPath -ChildPath $latestWingetMsixBundle
    $vcLibsFile = Join-Path -Path $tempFolderPath -ChildPath "Microsoft.VCLibs.x64.14.00.Desktop.appx"

    Write-Information "Downloading winget to artifacts directory..."
    Invoke-WebRequest -Uri $latestWingetMsixBundleUri -OutFile $latestWingetMsixBundlePath
    Invoke-WebRequest -Uri "https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx" -OutFile $vcLibsFile

    $FileVersion = (Get-ItemProperty -Path $vcLibsFile).VersionInfo.ProductVersion
    $HighestInstalledVersion = Get-AppxPackage -Name Microsoft.VCLibs* |
        Sort-Object -Property Version |
        Select-Object -ExpandProperty Version -Last 1
    if ( $HighestInstalledVersion -lt $FileVersion ) {
        Add-AppxPackage $vcLibsFile
    }
    Add-AppxPackage $latestWingetMsixBundlePath
}

function Enable-AutomaticLogon {
    param(
        [string]$UserName = $env:UserName,
        [string]$Domain,
        [Parameter(Mandatory=$true)]
        [SecureString]$Password
    )


    $userSID = (Get-WmiObject -Class Win32_UserAccount | Where-Object { $_.Name -eq $UserName }).SID
    Write-Information "Enabling automatic signin"
    # Automatic sign-in is just a few registry keys...
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "AutoAdminLogon" -Value "1"
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "DefaultUserName" -Value $UserName
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "DefaultPassword" -Value $Password
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "AutoLogonSID" -Value $userSID
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "dontdisplaylastusername" -Value "1"
    if ($Domain -ne $null) {
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "DefaultDomainName" -Value $Domain
    }
}

function Disable-AutomaticLogon {
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "AutoAdminLogon" -Value "0"
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "DefaultUserName" -Value "" 
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "DefaultPassword" -Value ""
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "AutoLogonSID" -Value $userSID
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "dontdisplaylastusername" -Value "0"
}

<#
    The MIT License (MIT)

    Copyright (c) 2016 QuietusPlus

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
#>

function Write-Menu {
    <#
        .SYNOPSIS
            Outputs a command-line menu which can be navigated using the keyboard.

        .DESCRIPTION
            Outputs a command-line menu which can be navigated using the keyboard.

            * Automatically creates multiple pages if the entries cannot fit on-screen.
            * Supports nested menus using a combination of hashtables and arrays.
            * No entry / page limitations (apart from device performance).
            * Sort entries using the -Sort parameter.
            * -MultiSelect: Use space to check a selected entry, all checked entries will be invoked / returned upon confirmation.
            * Jump to the top / bottom of the page using the "Home" and "End" keys.
            * "Scrolling" list effect by automatically switching pages when reaching the top/bottom.
            * Nested menu indicator next to entries.
            * Remembers parent menus: Opening three levels of nested menus means you have to press "Esc" three times.

            Controls             Description
            --------             -----------
            Up                   Previous entry
            Down                 Next entry
            Left / PageUp        Previous page
            Right / PageDown     Next page
            Home                 Jump to top
            End                  Jump to bottom
            Space                Check selection (-MultiSelect only)
            Enter                Confirm selection
            Esc / Backspace      Exit / Previous menu

        .EXAMPLE
            PS C:\>$menuReturn = Write-Menu -Title 'Menu Title' -Entries @('Menu Option 1', 'Menu Option 2', 'Menu Option 3', 'Menu Option 4')

            Output:

              Menu Title

               Menu Option 1
               Menu Option 2
               Menu Option 3
               Menu Option 4

        .EXAMPLE
            PS C:\>$menuReturn = Write-Menu -Title 'AppxPackages' -Entries (Get-AppxPackage).Name -Sort

            This example uses Write-Menu to sort and list app packages (Windows Store/Modern Apps) that are installed for the current profile.

        .EXAMPLE
            PS C:\>$menuReturn = Write-Menu -Title 'Advanced Menu' -Sort -Entries @{
                'Command Entry' = '(Get-AppxPackage).Name'
                'Invoke Entry' = '@(Get-AppxPackage).Name'
                'Hashtable Entry' = @{
                    'Array Entry' = "@('Menu Option 1', 'Menu Option 2', 'Menu Option 3', 'Menu Option 4')"
                }
            }

            This example includes all possible entry types:

            Command Entry     Invoke without opening as nested menu (does not contain any prefixes)
            Invoke Entry      Invoke and open as nested menu (contains the "@" prefix)
            Hashtable Entry   Opened as a nested menu
            Array Entry       Opened as a nested menu

        .NOTES
            Write-Menu by QuietusPlus (inspired by "Simple Textbased Powershell Menu" [Michael Albert])

        .LINK
            https://quietusplus.github.io/Write-Menu

        .LINK
            https://github.com/QuietusPlus/Write-Menu
    #>

    [CmdletBinding()]

    <#
        Parameters
    #>

    param(
        # Array or hashtable containing the menu entries
        [Parameter(Mandatory=$true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('InputObject')]
        $Entries,

        # Title shown at the top of the menu.
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('Name')]
        [string]
        $Title,

        # Sort entries before they are displayed.
        [Parameter()]
        [switch]
        $Sort,

        # Select multiple menu entries using space, each selected entry will then get invoked (this will disable nested menu's).
        [Parameter()]
        [switch]
        $MultiSelect
    )

    <#
        Configuration
    #>

    # Entry prefix, suffix and padding
    $script:cfgPrefix = ' '
    $script:cfgPadding = 2
    $script:cfgSuffix = ' '
    $script:cfgNested = ' >'

    # Minimum page width
    $script:cfgWidth = 30

    # Hide cursor
    [System.Console]::CursorVisible = $false

    # Save initial colours
    $script:colorForeground = [System.Console]::ForegroundColor
    $script:colorBackground = [System.Console]::BackgroundColor

    <#
        Checks
    #>

    # Check if entries has been passed
    if ($Entries -like $null) {
        Write-Error "Missing -Entries parameter!"
        return
    }

    # Check if host is console
    if ($host.Name -ne 'ConsoleHost') {
        Write-Error "[$($host.Name)] Cannot run inside current host, please use a console window instead!"
        return
    }

    <#
        Set-Color
    #>

    function Set-Color ([switch]$Inverted) {
        switch ($Inverted) {
            $true {
                [System.Console]::ForegroundColor = $colorBackground
                [System.Console]::BackgroundColor = $colorForeground
            }
            Default {
                [System.Console]::ForegroundColor = $colorForeground
                [System.Console]::BackgroundColor = $colorBackground
            }
        }
    }

    <#
        Get-Menu
    #>

    function Get-Menu ($script:inputEntries) {
        # Clear console
        Clear-Host

        # Check if -Title has been provided, if so set window title, otherwise set default.
        if ($Title -notlike $null) {
            $host.UI.RawUI.WindowTitle = $Title
            $script:menuTitle = "$Title"
        } else {
            $script:menuTitle = 'Menu'
        }

        # Set menu height
        $script:pageSize = ($host.UI.RawUI.WindowSize.Height - 5)

        # Convert entries to object
        $script:menuEntries = @()
        switch ($inputEntries.GetType().Name) {
            'String' {
                # Set total entries
                $script:menuEntryTotal = 1
                # Create object
                $script:menuEntries = New-Object PSObject -Property @{
                    Command = ''
                    Name = $inputEntries
                    Selected = $false
                    onConfirm = 'Name'
                }; break
            }
            'Object[]' {
                # Get total entries
                $script:menuEntryTotal = $inputEntries.Length
                # Loop through array
                foreach ($i in 0..$($menuEntryTotal - 1)) {
                    # Create object
                    $script:menuEntries += New-Object PSObject -Property @{
                        Command = ''
                        Name = $($inputEntries)[$i]
                        Selected = $false
                        onConfirm = 'Name'
                    }; $i++
                }; break
            }
            'Hashtable' {
                # Get total entries
                $script:menuEntryTotal = $inputEntries.Count
                # Loop through hashtable
                foreach ($i in 0..($menuEntryTotal - 1)) {
                    # Check if hashtable contains a single entry, copy values directly if true
                    if ($menuEntryTotal -eq 1) {
                        $tempName = $($inputEntries.Keys)
                        $tempCommand = $($inputEntries.Values)
                    } else {
                        $tempName = $($inputEntries.Keys)[$i]
                        $tempCommand = $($inputEntries.Values)[$i]
                    }

                    # Check if command contains nested menu
                    if ($tempCommand.GetType().Name -eq 'Hashtable') {
                        $tempAction = 'Hashtable'
                    } elseif ($tempCommand.Substring(0,1) -eq '@') {
                        $tempAction = 'Invoke'
                    } else {
                        $tempAction = 'Command'
                    }

                    # Create object
                    $script:menuEntries += New-Object PSObject -Property @{
                        Name = $tempName
                        Command = $tempCommand
                        Selected = $false
                        onConfirm = $tempAction
                    }; $i++
                }; break
            }
            Default {
                Write-Error "Type `"$($inputEntries.GetType().Name)`" not supported, please use an array or hashtable."
                exit
            }
        }

        # Sort entries
        if ($Sort -eq $true) {
            $script:menuEntries = $menuEntries | Sort-Object -Property Name
        }

        # Get longest entry
        $script:entryWidth = ($menuEntries.Name | Measure-Object -Maximum -Property Length).Maximum
        # Widen if -MultiSelect is enabled
        if ($MultiSelect) { $script:entryWidth += 4 }
        # Set minimum entry width
        if ($entryWidth -lt $cfgWidth) { $script:entryWidth = $cfgWidth }
        # Set page width
        $script:pageWidth = $cfgPrefix.Length + $cfgPadding + $entryWidth + $cfgPadding + $cfgSuffix.Length

        # Set current + total pages
        $script:pageCurrent = 0
        $script:pageTotal = [math]::Ceiling((($menuEntryTotal - $pageSize) / $pageSize))

        # Insert new line
        [System.Console]::WriteLine("")

        # Save title line location + write title
        $script:lineTitle = [System.Console]::CursorTop
        [System.Console]::WriteLine("  $menuTitle" + "`n")

        # Save first entry line location
        $script:lineTop = [System.Console]::CursorTop
    }

    <#
        Get-Page
    #>

    function Get-Page {
        # Update header if multiple pages
        if ($pageTotal -ne 0) { Update-Header }

        # Clear entries
        for ($i = 0; $i -le $pageSize; $i++) {
            # Overwrite each entry with whitespace
            [System.Console]::WriteLine("".PadRight($pageWidth) + ' ')
        }

        # Move cursor to first entry
        [System.Console]::CursorTop = $lineTop

        # Get index of first entry
        $script:pageEntryFirst = ($pageSize * $pageCurrent)

        # Get amount of entries for last page + fully populated page
        if ($pageCurrent -eq $pageTotal) {
            $script:pageEntryTotal = ($menuEntryTotal - ($pageSize * $pageTotal))
        } else {
            $script:pageEntryTotal = $pageSize
        }

        # Set position within console
        $script:lineSelected = 0

        # Write all page entries
        for ($i = 0; $i -le ($pageEntryTotal - 1); $i++) {
            Write-Entry $i
        }
    }

    <#
        Write-Entry
    #>

    function Write-Entry ([int16]$Index, [switch]$Update) {
        # Check if entry should be highlighted
        switch ($Update) {
            $true { $lineHighlight = $false; break }
            Default { $lineHighlight = ($Index -eq $lineSelected) }
        }

        # Page entry name
        $pageEntry = $menuEntries[($pageEntryFirst + $Index)].Name

        # Prefix checkbox if -MultiSelect is enabled
        if ($MultiSelect) {
            switch ($menuEntries[($pageEntryFirst + $Index)].Selected) {
                $true { $pageEntry = "[X] $pageEntry"; break }
                Default { $pageEntry = "[ ] $pageEntry" }
            }
        }

        # Full width highlight + Nested menu indicator
        switch ($menuEntries[($pageEntryFirst + $Index)].onConfirm -in 'Hashtable', 'Invoke') {
            $true { $pageEntry = "$pageEntry".PadRight($entryWidth) + "$cfgNested"; break }
            Default { $pageEntry = "$pageEntry".PadRight($entryWidth + $cfgNested.Length) }
        }

        # Write new line and add whitespace without inverted colours
        [System.Console]::Write("`r" + $cfgPrefix)
        # Invert colours if selected
        if ($lineHighlight) { Set-Color -Inverted }
        # Write page entry
        [System.Console]::Write("".PadLeft($cfgPadding) + $pageEntry + "".PadRight($cfgPadding))
        # Restore colours if selected
        if ($lineHighlight) { Set-Color }
        # Entry suffix
        [System.Console]::Write($cfgSuffix + "`n")
    }

    <#
        Update-Entry
    #>

    function Update-Entry ([int16]$Index) {
        # Reset current entry
        [System.Console]::CursorTop = ($lineTop + $lineSelected)
        Write-Entry $lineSelected -Update

        # Write updated entry
        $script:lineSelected = $Index
        [System.Console]::CursorTop = ($lineTop + $Index)
        Write-Entry $lineSelected

        # Move cursor to first entry on page
        [System.Console]::CursorTop = $lineTop
    }

    <#
        Update-Header
    #>

    function Update-Header {
        # Set corrected page numbers
        $pCurrent = ($pageCurrent + 1)
        $pTotal = ($pageTotal + 1)

        # Calculate offset
        $pOffset = ($pTotal.ToString()).Length

        # Build string, use offset and padding to right align current page number
        $script:pageNumber = "{0,-$pOffset}{1,0}" -f "$("$pCurrent".PadLeft($pOffset))","/$pTotal"

        # Move cursor to title
        [System.Console]::CursorTop = $lineTitle
        # Move cursor to the right
        [System.Console]::CursorLeft = ($pageWidth - ($pOffset * 2) - 1)
        # Write page indicator
        [System.Console]::WriteLine("$pageNumber")
    }

    <#
        Initialisation
    #>

    # Get menu
    Get-Menu $Entries

    # Get page
    Get-Page

    # Declare hashtable for nested entries
    $menuNested = [ordered]@{}

    <#
        User Input
    #>

    # Loop through user input until valid key has been pressed
    do { $inputLoop = $true

        # Move cursor to first entry and beginning of line
        [System.Console]::CursorTop = $lineTop
        [System.Console]::Write("`r")

        # Get pressed key
        $menuInput = [System.Console]::ReadKey($false)

        # Define selected entry
        $entrySelected = $menuEntries[($pageEntryFirst + $lineSelected)]

        # Check if key has function attached to it
        switch ($menuInput.Key) {
            # Exit / Return
            { $_ -in 'Escape', 'Backspace' } {
                # Return to parent if current menu is nested
                if ($menuNested.Count -ne 0) {
                    $pageCurrent = 0
                    $Title = $($menuNested.GetEnumerator())[$menuNested.Count - 1].Name
                    Get-Menu $($menuNested.GetEnumerator())[$menuNested.Count - 1].Value
                    Get-Page
                    $menuNested.RemoveAt($menuNested.Count - 1) | Out-Null
                # Otherwise exit and return $null
                } else {
                    Clear-Host
                    $inputLoop = $false
                    [System.Console]::CursorVisible = $true
                    return $null
                }; break
            }

            # Next entry
            'DownArrow' {
                if ($lineSelected -lt ($pageEntryTotal - 1)) { # Check if entry isn't last on page
                    Update-Entry ($lineSelected + 1)
                } elseif ($pageCurrent -ne $pageTotal) { # Switch if not on last page
                    $pageCurrent++
                    Get-Page
                }; break
            }

            # Previous entry
            'UpArrow' {
                if ($lineSelected -gt 0) { # Check if entry isn't first on page
                    Update-Entry ($lineSelected - 1)
                } elseif ($pageCurrent -ne 0) { # Switch if not on first page
                    $pageCurrent--
                    Get-Page
                    Update-Entry ($pageEntryTotal - 1)
                }; break
            }

            # Select top entry
            'Home' {
                if ($lineSelected -ne 0) { # Check if top entry isn't already selected
                    Update-Entry 0
                } elseif ($pageCurrent -ne 0) { # Switch if not on first page
                    $pageCurrent--
                    Get-Page
                    Update-Entry ($pageEntryTotal - 1)
                }; break
            }

            # Select bottom entry
            'End' {
                if ($lineSelected -ne ($pageEntryTotal - 1)) { # Check if bottom entry isn't already selected
                    Update-Entry ($pageEntryTotal - 1)
                } elseif ($pageCurrent -ne $pageTotal) { # Switch if not on last page
                    $pageCurrent++
                    Get-Page
                }; break
            }

            # Next page
            { $_ -in 'RightArrow','PageDown' } {
                if ($pageCurrent -lt $pageTotal) { # Check if already on last page
                    $pageCurrent++
                    Get-Page
                }; break
            }

            # Previous page
            { $_ -in 'LeftArrow','PageUp' } { # Check if already on first page
                if ($pageCurrent -gt 0) {
                    $pageCurrent--
                    Get-Page
                }; break
            }

            # Select/check entry if -MultiSelect is enabled
            'Spacebar' {
                if ($MultiSelect) {
                    switch ($entrySelected.Selected) {
                        $true { $entrySelected.Selected = $false }
                        $false { $entrySelected.Selected = $true }
                    }
                    Update-Entry ($lineSelected)
                }; break
            }

            # Select all if -MultiSelect has been enabled
            'Insert' {
                if ($MultiSelect) {
                    $menuEntries | ForEach-Object {
                        $_.Selected = $true
                    }
                    Get-Page
                }; break
            }

            # Select none if -MultiSelect has been enabled
            'Delete' {
                if ($MultiSelect) {
                    $menuEntries | ForEach-Object {
                        $_.Selected = $false
                    }
                    Get-Page
                }; break
            }

            # Confirm selection
            'Enter' {
                # Check if -MultiSelect has been enabled
                if ($MultiSelect) {
                    Clear-Host
                    # Process checked/selected entries
                    $menuEntries | ForEach-Object {
                        # Entry contains command, invoke it
                        if (($_.Selected) -and ($_.Command -notlike $null) -and ($entrySelected.Command.GetType().Name -ne 'Hashtable')) {
                            Invoke-Expression -Command $_.Command
                        # Return name, entry does not contain command
                        } elseif ($_.Selected) {
                            return $_.Name
                        }
                    }
                    # Exit and re-enable cursor
                    $inputLoop = $false
                    [System.Console]::CursorVisible = $true
                    break
                }

                # Use onConfirm to process entry
                switch ($entrySelected.onConfirm) {
                    # Return hashtable as nested menu
                    'Hashtable' {
                        $menuNested.$Title = $inputEntries
                        $Title = $entrySelected.Name
                        Get-Menu $entrySelected.Command
                        Get-Page
                        break
                    }

                    # Invoke attached command and return as nested menu
                    'Invoke' {
                        $menuNested.$Title = $inputEntries
                        $Title = $entrySelected.Name
                        Get-Menu $(Invoke-Expression -Command $entrySelected.Command.Substring(1))
                        Get-Page
                        break
                    }

                    # Invoke attached command and exit
                    'Command' {
                        Clear-Host
                        Invoke-Expression -Command $entrySelected.Command
                        $inputLoop = $false
                        [System.Console]::CursorVisible = $true
                        break
                    }

                    # Return name and exit
                    'Name' {
                        Clear-Host
                        return $entrySelected.Name
                        $inputLoop = $false
                        [System.Console]::CursorVisible = $true
                    }
                }
            }
        }
    } while ($inputLoop)
}

$PackageCollections = @{
    "General" = @(
        "7zip.7zip",
        "Git.Git",
        "agalwood.Motrix",
        "TheBrowserCompany.Arc",
        "Microsoft.WindowsTerminal",
        "Microsoft.PowerToys",
        "Microsoft.PowerShell",
        "Microsoft.OneDrive",
        "Microsoft.VisualStudioCode",
        "Logitech.OptionsPlus",
        "Python.Python.3.12",
        "Mozilla.Firefox",
        "9PP9GZM2GN26"
    )
    "Home" = @(
        "Discord.Discord"
    )
    "Work" = @(
        "Microsoft.Teams",
        "SlackTechnologies.Slack"
    )
    "Microsoft Office" = @("Microsoft.Office")
    "Bitwarden" = @(
        "Bitwarden.Bitwarden",
        "Bitwarden.CLI"
    )
    "Nvidia" = @(
        "Nvidia.Broadcast",
        "Nvidia.GeForceExperience",
        "Nvidia.PhysX"
    )
    "Development" = @(
        "Debian.Debian",
        "GitHub.cli",
        "JetBrains.ToolBox",
        "LLVM.LLVM",
        "Microsoft.DevHome",
        "Microsoft.VisualStudio.2022.BuildTools",
        "Microsoft.VisualStudio.2022.Community",
        "Microsoft.WingetCreate",
        "Nvim.Nvim",
        "RustLang.RustUp",
        "commercialhaskell.stack",
        "jqlang.jq",
        "SSHFS-Win.SSHFS-Win",
        "REALiX.HWiNFO",
        "Rufus.Rufus"
    )
    "Games" = @(
        "Microsoft.OpenJDK.21",
        "PrismLauncher.PrismLauncher",
        "Valve.Steam",
        "Jaquadro.NBTExplorer",
        "Mojang.MinecraftLauncher"
    )
    "SysInternals" = @(
        "Microsoft.Sysinternals.Sysmon",
        "Microsoft.Sysinternals.Strings",
        "Microsoft.Sysinternals.RDCMan",
        "Microsoft.Sysinternals.ProcessMonitor",
        "Microsoft.Sysinternals.ProcessExplorer",
        "Microsoft.Sysinternals.Handle",
        "Microsoft.Sysinternals.FindLinks",
        "Microsoft.Sysinternals.Desktops",
        "Microsoft.Sysinternals.BGInfo",
        "Microsoft.Sysinternals.Autoruns"
    )
}

$WindowsFeatures = @{
    "Hyper-V" = "Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All -NoRestart"
    "Microsoft Print to PDF" = "Enable-WindowsOptionalFeature -Online -FeatureName PrintToPDFServices -NoRestart"
    "Telnet Client" = "Enable-WindowsOptionalFeature -Online -FeatureName TelnetClient -NoRestart"
    "Virtual Machine Platform" = "Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart"
    "Windows Hypervisor Platform" = "Enable-WindowsOptionalFeature -Online -FeatureName HypervisorPlatform -NoRestart"
    "Windows Sandbox" = "Enable-WindowsOptionalFeature -Online -FeatureName Containers-DisposableClientVM -NoRestart"
    "Windows Subsystem for Linux" = "Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart"
 }

$Fonts = @(
    "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/JetBrainsMono.zip",
    "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/ComicShannsMono.zip"
)

$isDotSourced = $MyInvocation.InvocationName -eq '.' -or $MyInvocation.Line -eq ''
if ($isDotSourced) {
    exit 0
}

function Ask-ForRestart {
    if (Is-RunningAsAdmin) {
        Write-Warning "Changes may not be applied until you restart your PC"
    }
    if (Ask-Question -Title "Restart required" -Message "Restart your PC now?" -Default $true -CanAbort $false -No "Later" -YesDescription "Restart now" -NoDescription "Restart manually later on" -RequiresInput) {
        Restart-Computer -Force
    }
}

if (-not (Is-RunningAsAdmin)) {
    Write-Warning "Some features of this script are unavailable as a non-elevated user."
}

if ($InstallWinGet -or (Ask-Question -Title "Install WinGet" -Message "Install the latest WinGet package?" -Default $true)) {
    Write-Host "Installing WinGet"
    Install-WinGet
}
 
if ($InstallPackages -or (Ask-Question -Title "Install Packages" -Message "Select and install packages?" -Default $true)) {
    # If user uses -All flag, choose some workloads.
    if ($All) {
        $selectedCollections = @("General", "Microsoft Office", "Development", "Bitwarden", "SysInternals")
        # Detect Nvidia card for Nvidia workload.
        if (Get-WmiObject -Class Win32_PnPEntity | Where-Object { $_.Name -like "*NVIDIA*" }) {
            $selectedCollections += "Nvidia"
        }
        Write-Host "Automatically selected the following workloads to install:"
        foreach($coll in $selectedCollections) {
            Write-Host " - $coll"
        }
    } else {
        $selectedCollections = Write-Menu -Title 'Choose workloads' -MultiSelect -Entries @($PackageCollections.Keys)
    }
    foreach($coll in $selectedCollections) {
        Write-Host "Installing workload: $coll"
        foreach($pkg in $PackageCollections[$coll]) {
            Invoke-Expression -Command "winget install --exact --id $pkg"
        }
    }
}

#if ($InstallFonts -or (Ask-Question -Title "Install fonts" -Message "Download and install $($Fonts.Length) fonts?" -Default $true)) {
    #$tempFolderPath = [System.IO.Path]::GetTempPath()
    #foreach($fontUrl in $Fonts) {
        #Write-Information "Installing $fontUrl"
        #$fontZipName = $fontUrl.Split("/")[-1]
        #$fontFolderName = $fontZipName.Substring(0, $fontZipName.LastIndexOf('.'))
        #$downloadPath = Join-Path -Path $tempFolderPath -ChildPath $fontZipName
        #$unzippedPath = Join-Path -Path $tempFolderPath -ChildPath $fontFolderName 
        #Invoke-WebRequest -Uri $fontUrl -OutFile $downloadPath
        #if (Test-Path $unzippedPath -PathType Container) { 
            #Remove-Item -Path $unzippedPath -Recurse -Force
        #}
        #Expand-Archive -Path $downloadPath -DestinationPath $unzippedPath
        #$fontFiles = Get-ChildItem -Path $unzippedPath -Include *.ttf, *.otf, *.fon, *.fnt 
        #foreach ($fontFile in $fontFiles) {
            #Add-Font -File $fontFile
        #} 
        #Remove-Item -Path $downloadPath -Force
        #Remove-Item -Path $unzippedPath -Force -Recurse
    #}
#}

if (-not (Is-RunningAsAdmin)) {
    Write-Host "Re-run in an administrator prompt to configure login and optional windows features."
    Ask-ForRestart
    exit 0
}

if ($AutoLogin -or (Ask-Question -Title "Auto Login" -Message "Configure automatic login?" -Default $false)) {
    if (Ask-Question -Title "Configure automatic login" -Message "Setup automatic login for the current user?" -Yes "This User" -No "Another User" -YesDescription "Log this user in automatically" -NoDescription "Log in a different user automatically" -CanAbort $false -Default $true -RequiresInput) {
        $credential = Get-Credential -UserName $env:UserName -Message "Enter your windows account credentials"
    } else {
        $credential = Get-Credential -Message "Enter your windows account credentials"
    }
    Enable-AutomaticLogon -UserName $credential.UserName -Password $credential.Password
}

if (Ask-Question -Title "Optional Windows Features" -Message "Select and enable Windows Features?" -Default $true) {
    $selectedCollections = Write-Menu -Title 'Choose features' -MultiSelect -Entries $WindowsFeatures
}

Ask-ForRestart
