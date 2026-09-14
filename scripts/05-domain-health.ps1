<#
.SYNOPSIS
Performs basic Active Directory and Domain Controller health checks.

.DESCRIPTION
Checks domain information, Domain Controller discovery,
DNS resolution, critical Windows services, and basic
Active Directory queries.

Run this script on the Domain Controller.
#>

#Requires -RunAsAdministrator

Import-Module ActiveDirectory

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host " Domain Controller Health Check" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

# Check domain information
try {
    $Domain = Get-ADDomain -ErrorAction Stop

    Write-Host ""
    Write-Host "[+] Domain detected: $($Domain.DNSRoot)" -ForegroundColor Green
}
catch {
    Write-Host ""
    Write-Host "[X] Unable to retrieve domain information." -ForegroundColor Red
    Write-Host $_.Exception.Message
    exit 1
}

# Discover the Domain Controller
try {
    $DC = Get-ADDomainController `
        -Discover `
        -DomainName $Domain.DNSRoot `
        -ErrorAction Stop

    Write-Host "[+] Domain Controller: $($DC.HostName)" -ForegroundColor Green
    Write-Host "[+] DC IP Address: $($DC.IPv4Address)" -ForegroundColor Green
}
catch {
    Write-Host "[X] Unable to locate a Domain Controller." -ForegroundColor Red
}

# Test DNS
Write-Host ""
Write-Host "DNS Test"
Write-Host "--------"

try {
    $DNSResult = Resolve-DnsName `
        $Domain.DNSRoot `
        -ErrorAction Stop

    Write-Host "[+] DNS resolution successful." -ForegroundColor Green

    $DNSResult |
        Select-Object Name, Type, IPAddress |
        Format-Table -AutoSize
}
catch {
    Write-Host "[X] DNS resolution failed." -ForegroundColor Red
}

# Check critical services
Write-Host ""
Write-Host "Service Status"
Write-Host "--------------"

$CriticalServices = @(
    "NTDS",
    "DNS",
    "Netlogon"
)

foreach ($ServiceName in $CriticalServices) {

    $Service = Get-Service `
        -Name $ServiceName `
        -ErrorAction SilentlyContinue

    if (-not $Service) {
        Write-Host "[X] $ServiceName service not found." -ForegroundColor Red
        continue
    }

    if ($Service.Status -eq "Running") {
        Write-Host "[+] $ServiceName is running." -ForegroundColor Green
    }
    else {
        Write-Host "[X] $ServiceName is $($Service.Status)." -ForegroundColor Red
    }
}

# Test Active Directory queries
Write-Host ""
Write-Host "Active Directory Tests"
Write-Host "----------------------"

try {
    $Users = @(Get-ADUser -Filter *)
    $Computers = @(Get-ADComputer -Filter *)
    $Groups = @(Get-ADGroup -Filter *)

    Write-Host "[+] Active Directory queries successful." -ForegroundColor Green
    Write-Host "Users:     $($Users.Count)"
    Write-Host "Computers: $($Computers.Count)"
    Write-Host "Groups:    $($Groups.Count)"
}
catch {
    Write-Host "[X] Active Directory query failed." -ForegroundColor Red
    Write-Host $_.Exception.Message
}

Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host " Health Check Complete" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Cyan
