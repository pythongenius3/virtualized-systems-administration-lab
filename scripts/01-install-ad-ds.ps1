<#
.SYNOPSIS
Installs Active Directory Domain Services and creates the lab.local forest.

.DESCRIPTION
Installs the Active Directory Domain Services role and promotes the
Windows Server VM to a domain controller for the lab.local domain.

Run this script on the Windows Server VM as Administrator.
#>

#Requires -RunAsAdministrator

$DomainName = "lab.local"
$NetBIOSName = "LAB"

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host " Active Directory Deployment" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

$OS = Get-CimInstance Win32_OperatingSystem

Write-Host ""
Write-Host "[+] Computer: $env:COMPUTERNAME"
Write-Host "[+] Operating System: $($OS.Caption)"
Write-Host "[+] Target Domain: $DomainName"

$ADDSFeature = Get-WindowsFeature -Name AD-Domain-Services

if ($ADDSFeature.Installed) {
    Write-Host ""
    Write-Host "[=] Active Directory Domain Services is already installed." -ForegroundColor Yellow
}
else {
    Write-Host ""
    Write-Host "[*] Installing Active Directory Domain Services..." -ForegroundColor Yellow

    $InstallResult = Install-WindowsFeature `
        -Name AD-Domain-Services `
        -IncludeManagementTools

    if (-not $InstallResult.Success) {
        Write-Host "[X] AD DS installation failed." -ForegroundColor Red
        exit 1
    }

    Write-Host "[+] AD DS installed successfully." -ForegroundColor Green
}

if (-not (Get-Module -ListAvailable -Name ADDSDeployment)) {
    Write-Host "[X] ADDSDeployment PowerShell module was not found." -ForegroundColor Red
    exit 1
}

Import-Module ADDSDeployment

Write-Host ""
Write-Host "[*] Preparing to create the $DomainName forest..." -ForegroundColor Yellow

$DSRMPassword = Read-Host `
    "Enter a Directory Services Restore Mode password" `
    -AsSecureString

Write-Host ""
Write-Host "[!] Server promotion is about to begin." -ForegroundColor Yellow
Write-Host "[!] The server will restart automatically when complete." -ForegroundColor Yellow

Install-ADDSForest `
    -DomainName $DomainName `
    -DomainNetbiosName $NetBIOSName `
    -InstallDNS `
    -SafeModeAdministratorPassword $DSRMPassword `
    -Force
