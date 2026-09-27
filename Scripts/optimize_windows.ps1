# optimize_windows.ps1
# WARNING: This script aggressively disables core Windows features to maximize emulator performance.

Write-Host "Starting A15 Handheld Windows Optimization..." -ForegroundColor Green

# 1. Disable Windows Defender & Real-Time Protection
# Defender's background scanning will stall the QEMU drive emulator.
Write-Host "Disabling Windows Defender..."
Set-MpPreference -DisableRealtimeMonitoring $true
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name "DisableAntiSpyware" -Value 1 -PropertyType DWORD -Force

# 2. Kill Windows Telemetry & Data Collection
# Stops Windows from using CPU cycles to phone home to Microsoft.
Write-Host "Disabling Telemetry..."
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0
Stop-Service -Name "DiagTrack" -Force
Set-Service -Name "DiagTrack" -StartupType Disabled

# 3. Disable Search Indexing
# Indexing thrashes the emulated NVMe drive. We don't need it for a retro console.
Write-Host "Disabling Windows Search Indexer..."
Stop-Service -Name "WSearch" -Force
Set-Service -Name "WSearch" -StartupType Disabled

# 4. Strip UWP Bloatware (Candy Crush, Xbox App, etc.)
Write-Host "Removing default bloatware apps..."
Get-AppxPackage -AllUsers | Where-Object {$_.Name -notmatch "Store|Calculator|Photos"} | Remove-AppxPackage
Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -notmatch "Store|Calculator|Photos"} | Remove-AppxProvisionedPackage -Online

# 5. Disable Visual Effects (Set to 'Best Performance')
# Offloads UI rendering stress from the emulated GPU.
Write-Host "Optimizing Visual Effects..."
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 2

# 6. Disable Xbox Game Bar & DVR
# Game DVR recording destroys frame rates on low-end/emulated hardware.
Write-Host "Disabling Xbox Game DVR..."
Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Name "AllowGameDVR" -Value 0

Write-Host "Optimization Complete! Reboot the virtual machine to apply changes." -ForegroundColor Cyan