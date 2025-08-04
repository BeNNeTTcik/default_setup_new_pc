# Temporary directory for downloads
$tempDir = "$env:TEMP\instalki"
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

# Fucntion to install applications
function Install-App {
    param (
        [string]$Name,
        [string]$Url,
        [string]$Installer,
        [string]$Arguments
    )
    $installerPath = "$tempDir\$Installer"
    Invoke-WebRequest -Uri $Url -OutFile $installerPath
    Start-Process -FilePath $installerPath -ArgumentList $Arguments -Wait -NoNewWindow
}

# Adobe Reader Installation
Install-App -Name "Adobe Reader" `
    -Url "https://ardownload2.adobe.com/pub/adobe/reader/win/AcrobatDC/2300320197/AcroRdrDC2300320197_en_US.exe" `
    -Installer "adobe.exe" `
    -Arguments "/sAll /rs /rps /msi EULA_ACCEPT=YES"

    https://get.adobe.com/pl/reader/download?os=Windows+10&name=Reader+2025.001.20531+Polish+Windows%2864Bit%29&lang=pl&nativeOs=Windows+10&accepted=cr&declined=mss&preInstalled=&site=landing