<#
.SYNOPSIS
Creates and links a basic workstation Group Policy Object.

.DESCRIPTION
Creates a Group Policy Object named "Lab Workstation Baseline"
and configures a 15-minute machine inactivity timeout.

The GPO is linked to the Workstations OU.

Run this script on the Domain Controller.
#>

#Requires -RunAsAdministrator

Import-Module ActiveDirectory
Import-Module GroupPolicy

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host " Group Policy Configuration" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

$Domain = Get-ADDomain
$DomainDN = $Domain.DistinguishedName

$GPOName = "Lab Workstation Baseline"
$WorkstationsOU = "OU=Workstations,$DomainDN"

Write-Host ""
Write-Host "[+] Domain: $($Domain.DNSRoot)"
Write-Host "[+] Target OU: $WorkstationsOU"

$ExistingGPO = Get-GPO `
    -Name $GPOName `
    -ErrorAction SilentlyContinue

if (-not $ExistingGPO) {

    Write-Host ""
    Write-Host "[*] Creating GPO: $GPOName" -ForegroundColor Yellow

    New-GPO `
        -Name $GPOName `
        -Comment "Baseline workstation configuration for systems administration lab"

    Write-Host "[+] GPO created successfully." -ForegroundColor Green
}
else {
    Write-Host ""
    Write-Host "[=] GPO already exists: $GPOName" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "[*] Configuring 15-minute inactivity timeout..." -ForegroundColor Yellow

Set-GPRegistryValue `
    -Name $GPOName `
    -Key "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" `
    -ValueName "InactivityTimeoutSecs" `
    -Type DWord `
    -Value 900

Write-Host "[+] Inactivity timeout configured for 900 seconds." -ForegroundColor Green

$Inheritance = Get-GPInheritance -Target $WorkstationsOU

$ExistingLink = $Inheritance.GpoLinks |
    Where-Object {
        $_.DisplayName -eq $GPOName
    }

if (-not $ExistingLink) {

    Write-Host ""
    Write-Host "[*] Linking GPO to Workstations OU..." -ForegroundColor Yellow

    New-GPLink `
        -Name $GPOName `
        -Target $WorkstationsOU `
        -LinkEnabled Yes

    Write-Host "[+] GPO linked successfully." -ForegroundColor Green
}
else {
    Write-Host ""
    Write-Host "[=] GPO is already linked to the Workstations OU." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host " Group Policy Setup Complete" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Cyan

Write-Host ""
Write-Host "GPO Summary:"

Get-GPO -Name $GPOName |
    Select-Object DisplayName, GpoStatus, CreationTime, ModificationTime |
    Format-List
