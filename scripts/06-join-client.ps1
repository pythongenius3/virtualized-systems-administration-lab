<#
.SYNOPSIS
Joins a Windows client workstation to the lab.local domain.

.DESCRIPTION
Checks connectivity and DNS resolution before joining the
Windows client VM to the Active Directory domain.

Run this script on the Windows client as Administrator.
#>

#Requires -RunAsAdministrator

$DomainName = "lab.local"
$DomainController = "192.168.56.10"

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host " Windows Client Domain Join" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

Write-Host ""
Write-Host "[*] Testing connectivity to Domain Controller..."

$Connection = Test-Connection `
    -ComputerName $DomainController `
    -Count 2 `
    -Quiet

if (-not $Connection) {

    Write-Host "[X] Unable to reach $DomainController" -ForegroundColor Red

    Write-Host ""
    Write-Host "Verify:"
    Write-Host "1. Both virtual machines are running"
    Write-Host "2. Both virtual machines use the same VirtualBox network"
    Write-Host "3. The Domain Controller IP is correct"
    Write-Host "4. Windows Firewall is not blocking required traffic"

    exit 1
}

Write-Host "[+] Domain Controller is reachable." -ForegroundColor Green

Write-Host ""
Write-Host "[*] Testing DNS resolution for $DomainName..."

try {

    Resolve-DnsName `
        $DomainName `
        -ErrorAction Stop |
        Out-Null

    Write-Host "[+] DNS resolution successful." -ForegroundColor Green
}
catch {

    Write-Host "[X] DNS resolution failed." -ForegroundColor Red

    Write-Host ""
    Write-Host "Configure the client's DNS server as:"
    Write-Host $DomainController

    exit 1
}

Write-Host ""
Write-Host "[*] Enter domain administrator credentials."

$Credential = Get-Credential `
    -Message "Enter LAB domain administrator credentials"

try {

    Add-Computer `
        -DomainName $DomainName `
        -Credential $Credential `
        -ErrorAction Stop

    Write-Host ""
    Write-Host "[+] Computer successfully joined to $DomainName" -ForegroundColor Green

    Write-Host ""
    Write-Host "[!] Restarting computer in 10 seconds..." -ForegroundColor Yellow

    Start-Sleep -Seconds 10

    Restart-Computer -Force
}
catch {

    Write-Host ""
    Write-Host "[X] Domain join failed." -ForegroundColor Red
    Write-Host $_.Exception.Message
}
