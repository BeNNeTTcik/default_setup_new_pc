# PowerShell script for setting up a new computer, installing applications, and modifying Windows settings by BeNNeTTcik
#
# This script is designed to run on a new computer to automate the installation of necessary applications.
# The program consists of five options:
# "[1] Install Chrome"
# "[2] Install Adobe Reader"
# "[3] Install MS Office 2024 LTS"
# "[4] Change the toolbar"
# "[5] Clean up disk"
#
# All operations can be run from the command line or the PowerShell console.

# ===========   VARIABLES   =======================

$samba = "\\DESKTOP-EFFK073\dane"               # path to shared folder with installation files
$downloadPath = "$env:USERPROFILE\Downloads"    # path to download folder

# DISK FORMATE SETTINGS
#$diskNumber = 0            # number of disk to format; to check use 'Get-Disk' command in PowerShell
#$label = "Dane"            # name of new volume
#$fileSystem = "NTFS"       # file system type

# ===========   FUNCTIONS   ======================

# Credential to shared folder and paste files to download folder
$cred = Get-Credential
New-PSDrive -Name Z -PSProvider FileSystem -Root $samba -Credential $cred -Persist
Copy-Item -Path "Z:\ChromeSetup.exe" -Destination "$downloadPath\ChromeSetup.exe" -Verbose
Copy-Item -Path "Z:\Reader_pl_install.exe" -Destination "$downloadPath\Reader_pl_install.exe" -Verbose
Copy-Item -Path "Z:\setup.exe" -Destination "$downloadPath\setup.exe" -Verbose
Copy-Item -Path "Z:\Configuration.xml" -Destination "$downloadPath\Configuration.xml" -Verbose
Remove-PSDrive -Name Z 
Write-Host "Files copied from `"$samba`""

# InstallAdobe function
function InstallAdobe {
    #REGEDIT
    Write-Host ">>> Adobe Installation"
    $adobePolicies = 'HKLM:\SOFTWARE\Policies\Adobe\Acrobat Reader\DC\FeatureLockDown'
    New-Item -Path $adobePolicies -Force | Out-Null
    New-ItemProperty -Path $adobePolicies -Name 'bToggleFTE' -Value 0 -PropertyType DWord -Force | Out-Null        # pomija First-Time Experience
    New-ItemProperty -Path $adobePolicies -Name 'bDisablePDFHandlerSwitching' -Value 1 -PropertyType DWord -Force | Out-Null  # nie pytaj o bycie domyślnym

    $installerPath = "$downloadPath\Reader_pl_install.exe"
    $proc = Start-Process -FilePath $installerPath -ArgumentList "/sAll /rs /rps /msi EULA_ACCEPT=YES SUPPRESS_APP_LAUNCH=YES DISABLE_ARM_SERVICE_INSTALL=1" -PassThru 
    
    $timeout = 600  
    $elapsed = 0
    
    while (!$proc.HasExited -and $elapsed -lt $timeout) {
        Start-Sleep -Seconds 10
        $elapsed += 10
    }

    if (!$proc.HasExited) {
        Stop-Process -Id $proc.Id -Force
    }

    $adobe = "AcroRd32", "Acrobat", "AcroCEF", "AdobeARM", "AdobeARMservice"

    foreach ($p in $adobe) {
        Get-Process -Name $p -ErrorAction SilentlyContinue |
        Stop-Process -Force
    }
    if ($proc.HasExited) {
        exit $proc.ExitCode
    }
    else {
        Write-Host 'ExitCode "0" = App Installed'
        exit 0
    }
}

# InstallChrome function
function InstallChrome {
    Write-Host ">>> Chrome Installation"
    # REGEDIT
    $chromePolicies = "HKLM:\SOFTWARE\Policies\Google\Chrome"
    New-Item -Path $chromePolicies -Force | Out-Null

    # Skip Welcome / First Run Settings
    New-ItemProperty -Path $chromePolicies -Name "SuppressFirstRunDefaultBrowserPrompt" -Value 1 -PropertyType DWord -Force | Out-Null
    New-ItemProperty -Path $chromePolicies -Name "BrowserAddPersonEnabled" -Value 0 -PropertyType DWord -Force | Out-Null

    # Skip Ask About Default Browser
    New-ItemProperty -Path $chromePolicies -Name "DefaultBrowserSettingEnabled" -Value 0 -PropertyType DWord -Force | Out-Null

    # Skip Ask About Raports For Google
    New-ItemProperty -Path $chromePolicies -Name "MetricsReportingEnabled" -Value 0 -PropertyType DWord -Force | Out-Null

    # Skip Ask About Bookmarks And Settings
    New-ItemProperty -Path $chromePolicies -Name "ImportBookmarks" -Value 0 -PropertyType DWord -Force | Out-Null
    New-ItemProperty -Path $chromePolicies -Name "ImportHistory" -Value 0 -PropertyType DWord -Force | Out-Null
    New-ItemProperty -Path $chromePolicies -Name "ImportHomepage" -Value 0 -PropertyType DWord -Force | Out-Null
    New-ItemProperty -Path $chromePolicies -Name "ImportSavedPasswords" -Value 0 -PropertyType DWord -Force | Out-Null
    New-ItemProperty -Path $chromePolicies -Name "ImportSearchEngine" -Value 0 -PropertyType DWord -Force | Out-Null

    $installerPath = "$downloadPath\ChromeSetup.exe"
    $q = Start-Process -FilePath $installerPath -ArgumentList "/qn /norestart" -Wait -PassThru
    $q.WaitForExit()
    Write-Host "ExitCode `"$($q.ExitCode)`" if 0 == App Installed"
}

# Start-change function (change 'Start' option on toolbar on left side position)
function ChangeToolbar {
    Write-Host ">>> Change Toolbar Posission"
    $Reg = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    $ValueName = "TaskbarAl"
    Set-ItemProperty -Path $Reg -Name $ValueName -Value 0
    Write-Host "Toolbar Settings Changed"
}

# InstallOffice function
function InstallOffice {
    Write-Host ">>> Office 2024 LTS Installation"
    $installerPath = "$downloadPath\setup.exe"
    $configureFile = "$downloadPath\Configuration.xml"
    $r = Start-Process cmd.exe -ArgumentList "/c cd `"$downloadPath`" && setup /configure `"$configureFile`"" -Wait -PassThru -Verb RunAs
    $r.WaitForExit()
    Write-Host "ExitCode `"$($r.ExitCode)`" if 0 == App Installed"
}

# Windows Update function
function UpdateWindows {
    Write-Host ">>> Updating Windows"
    Install-Module -Name PSWindowsUpdate -Force -Confirm:$false
    Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
    Import-Module PSWindowsUpdate
    Get-WindowsUpdate -MicrosoftUpdate -Install -AcceptAll -IgnoreReboot
    Write-Host "All Updates Installed"
    exit 0
}

# Default App
function SetDefaultApp {
    function TestAppInstalled {
        param([string]$Path)
        return Test-Path $Path
    }
    $chromePaths = "C:\Program Files\Google\Chrome\Application\chrome.exe"
    $chromeInstalled = $false
    foreach ($path in $chromePaths) {
        if (Test-AppInstalled $path) {
            $chromeInstalled = $true
            Write-Host "  [✓] Chrome znaleziony: $path" -ForegroundColor Green
            break
        }
    }
    if ($chromeInstalled) {
        # Ustaw Chrome jako domyślny
        $regPath = "HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations"
        $protocols = @("http", "https", "ftp")
    
        foreach ($protocol in $protocols) {
            $fullPath = "$regPath\$protocol\UserChoice"
            if (Test-Path $fullPath) {
                Remove-Item $fullPath -Force -ErrorAction SilentlyContinue
            }
        }
    
        Write-Host "  [→] Chrome ustawiony jako domyślny" -ForegroundColor Cyan
    }
    else {
        Write-Host "  [!] Chrome nie zainstalowany" -ForegroundColor Yellow
    }
    exit 0
}

# ClearDisk function
function ClearDisk {
    Write-Host ">>> Clear & Prepare Disk on Data"
    ClearDisk -Number $diskNumber -RemoveData -Confirm:$false
    Initialize-Disk -Number $diskNumber -PartitionStyle MBR
    New-Partition -DiskNumber $diskNumber -UseMaximumSize -AssignDriveLetter | Format-Volume -FileSystem $fileSystem -NewFileSystemLabel $label -Confirm:$false
}

# Clear Installation Files function
function ClearInstallationFiles {
    Write-Host ">>> Cleaning after all"
    if (Test-Path "$downloadPath\ChromeSetup.exe") {
        Remove-Item "$downloadPath\ChromeSetup.exe" -Force
    }
    if (Test-Path "$downloadPath\setup.exe") {
        Remove-Item "$downloadPath\setup.exe" -Force
    }
    if (Test-Path "$downloadPath\Reader_pl_install.exe") {
        Remove-Item "$downloadPath\Reader_pl_install.exe" -Force
    }
    if (Test-Path "$downloadPath\Configuration.xml") {
        Remove-Item "$downloadPath\Configuration.xml" -Force
    }
    Write-Host "All Installation Files Removed"
}

# ================ MAIN   LOOP   =====================

try {
    # MENU section
    Write-Host "What u want to install (e.g. 1,2,4)"
    Write-Host "[1] Install Chrome"
    Write-Host "[2] Install Adobe Reader"
    Write-Host "[3] Install MS Office 2024 LTS"
    Write-Host "[4] Change the toolbar"
    Write-Host "[5] Update Windows & drivers"
    Write-Host "[6] Clean up disk"
    Write-Host "[7] Set Default App"
    Write-Host ""
    $choice = Read-Host "Choose options (e.g. 1,2,4)"
    $selected = $choice -split ',' | ForEach-Object { $_.Trim() }

    foreach ($s in $selected) {
        switch ($s) {
            '1' { InstallChrome }
            '2' { InstallAdobe }
            '3' { InstallOffice }
            '4' { ChangeToolbar }
            '5' { UpdateWindows }
            '6' { ClearDisk }
            '7' { SetDefaultApp}
            default { Write-Warning "Undefined value: $s" }
        }
    }
}
finally {
    # Cleanup section
    ClearInstallationFiles
}
Write-Host "Installation complete. The last thing to do is change the default application in .pdf files => Adobe and .html files -> Chrome"