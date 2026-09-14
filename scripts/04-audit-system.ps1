<#
.SYNOPSIS
Collects Windows system information for the lab.

.DESCRIPTION
Audits system configuration, networking, firewall state,
disk usage, running services, and recent Windows System errors.
#>

#Requires -RunAsAdministrator

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host " Windows System Audit" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

$ScriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectDirectory = Split-Path -Parent $ScriptDirectory
$ReportsDirectory = Join-Path $ProjectDirectory "reports"

if (-not (Test-Path $ReportsDirectory)) {
    New-Item -ItemType Directory -Path $ReportsDirectory | Out-Null
}

$OS = Get-CimInstance Win32_OperatingSystem
$ComputerSystem = Get-CimInstance Win32_ComputerSystem

$Network = Get-NetIPConfiguration |
    Select-Object InterfaceAlias, IPv4Address, IPv4DefaultGateway, DNSServer

$Firewall = Get-NetFirewallProfile |
    Select-Object Name, Enabled, DefaultInboundAction, DefaultOutboundAction

$Disks = Get-CimInstance Win32_LogicalDisk -Filter "DriveType = 3" |
    Select-Object `
        DeviceID,
        @{
            Name = "SizeGB"
            Expression = {
                [math]::Round($_.Size / 1GB, 2)
            }
        },
        @{
            Name = "FreeSpaceGB"
            Expression = {
                [math]::Round($_.FreeSpace / 1GB, 2)
            }
        }

$RunningServices = Get-Service |
    Where-Object Status -eq "Running" |
    Select-Object Name, DisplayName, Status

$RecentErrors = Get-WinEvent `
    -FilterHashtable @{
        LogName   = "System"
        Level     = 2
        StartTime = (Get-Date).AddDays(-7)
    } `
    -ErrorAction SilentlyContinue |
    Select-Object `
        TimeCreated,
        Id,
        ProviderName,
        LevelDisplayName,
        Message

$Audit = [PSCustomObject]@{
    Timestamp = Get-Date

    Computer = [PSCustomObject]@{
        ComputerName = $env:COMPUTERNAME
        Domain       = $ComputerSystem.Domain
        Manufacturer = $ComputerSystem.Manufacturer
        Model        = $ComputerSystem.Model
    }

    OperatingSystem = [PSCustomObject]@{
        Caption      = $OS.Caption
        Version      = $OS.Version
        BuildNumber  = $OS.BuildNumber
        Architecture = $OS.OSArchitecture
        LastBootTime = $OS.LastBootUpTime
    }

    Network         = $Network
    Firewall        = $Firewall
    Disks           = $Disks
    RunningServices = $RunningServices
}

$JSONFile = Join-Path $ReportsDirectory "system-audit.json"
$TextFile = Join-Path $ReportsDirectory "system-audit.txt"
$ErrorFile = Join-Path $ReportsDirectory "recent-system-errors.csv"

$Audit |
    ConvertTo-Json -Depth 6 |
    Out-File -FilePath $JSONFile -Encoding UTF8

$RecentErrors |
    Export-Csv -Path $ErrorFile -NoTypeInformation

@"
SYSTEM AUDIT REPORT
===================

Timestamp:
$(Get-Date)

Computer:
$env:COMPUTERNAME

Domain:
$($ComputerSystem.Domain)

Operating System:
$($OS.Caption)

OS Version:
$($OS.Version)

Architecture:
$($OS.OSArchitecture)

Last Boot:
$($OS.LastBootUpTime)

Network Configuration
---------------------
$($Network | Format-List | Out-String)

Firewall Profiles
-----------------
$($Firewall | Format-Table -AutoSize | Out-String)

Disk Information
----------------
$($Disks | Format-Table -AutoSize | Out-String)

Running Services:
$($RunningServices.Count)

System Errors During Last 7 Days:
$($RecentErrors.Count)

"@ | Out-File -FilePath $TextFile -Encoding UTF8

Write-Host ""
Write-Host "[+] Audit complete." -ForegroundColor Green

Write-Host ""
Write-Host "Reports created:"
Write-Host " - $JSONFile"
Write-Host " - $TextFile"
Write-Host " - $ErrorFile"
