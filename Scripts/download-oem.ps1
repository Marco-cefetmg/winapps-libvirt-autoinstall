Start-Transcript -Path $env:TEMP\oem.log -Append

$baseUrl = "https://github.com/winapps-org/winapps/raw/refs/heads/main/oem/"
$filesToDownload = @( "install.bat", "RDPApps.reg", "NetProfileCleanup.ps1", "TimeSync.ps1" )
$destDir = "$env:TEMP\oem"

if (-not (Test-Path $destDir)) {
    New-Item -ItemType Directory -Path $destDir -Force | Out-Null
}

foreach ($file in $filesToDownload) {
    try {
        $destPath = Join-Path $destDir $file
        Write-Host "Downloading: $file" -ForegroundColor Yellow
        Invoke-WebRequest -Uri $($baseUrl + $file) -OutFile $destPath
    } catch {
        Write-Host "Error downloading $file : $($_.Exception.Message)" -ForegroundColor Red
    }
}

Try {
    Write-Host "Executing install.bat..." -ForegroundColor Yellow
    Start-Process -FilePath $(Join-Path $destDir install.bat) -Verb RunAs -Wait -ErrorAction Stop
    Write-Host "install.bat executed successfully." -ForegroundColor Green

    Write-Host "Cleaning..." -ForegroundColor Yellow
    Remove-Item $destDir -Recurse -Force
    Write-Host "Done!" -ForegroundColor Green
}
Catch {
    Write-Host "Error executing install.bat: $($_.Exception.Message)" -ForegroundColor Red
}

Stop-Transcript