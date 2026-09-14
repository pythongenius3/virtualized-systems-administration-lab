<#
.SYNOPSIS
Creates Organizational Units, security groups, and test users
for the virtualized systems administration lab.

.DESCRIPTION
This script configures the core Active Directory structure used
in the lab.local domain.

Run this script on the Domain Controller after AD DS has been deployed.
#>

#Requires -RunAsAdministrator

Import-Module ActiveDirectory

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host " Active Directory Structure Setup" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

$Domain = Get-ADDomain
$DomainDN = $Domain.DistinguishedName

Write-Host ""
Write-Host "[+] Domain: $($Domain.DNSRoot)"
Write-Host "[+] Distinguished Name: $DomainDN"

$OUs = @(
    "IT",
    "Users",
    "Workstations",
    "Groups"
)

foreach ($OU in $OUs) {

    $ExistingOU = Get-ADOrganizationalUnit `
        -Filter "Name -eq '$OU'" `
        -SearchBase $DomainDN `
        -ErrorAction SilentlyContinue

    if (-not $ExistingOU) {

        New-ADOrganizationalUnit `
            -Name $OU `
            -Path $DomainDN `
            -ProtectedFromAccidentalDeletion $true

        Write-Host "[+] Created OU: $OU" -ForegroundColor Green
    }
    else {
        Write-Host "[=] OU already exists: $OU" -ForegroundColor Yellow
    }
}

$GroupsOU = "OU=Groups,$DomainDN"

$Groups = @(
    "IT-Admins",
    "Helpdesk",
    "Standard-Users"
)

foreach ($Group in $Groups) {

    $ExistingGroup = Get-ADGroup `
        -Filter "Name -eq '$Group'" `
        -ErrorAction SilentlyContinue

    if (-not $ExistingGroup) {

        New-ADGroup `
            -Name $Group `
            -SamAccountName $Group `
            -GroupCategory Security `
            -GroupScope Global `
            -Path $GroupsOU

        Write-Host "[+] Created security group: $Group" -ForegroundColor Green
    }
    else {
        Write-Host "[=] Security group already exists: $Group" -ForegroundColor Yellow
    }
}

$UsersOU = "OU=Users,$DomainDN"
$ITOU = "OU=IT,$DomainDN"

$Users = @(
    @{
        FirstName  = "Alex"
        LastName   = "Admin"
        SamAccount = "alex.admin"
        OU         = $ITOU
        Group      = "IT-Admins"
    },
    @{
        FirstName  = "Jordan"
        LastName   = "User"
        SamAccount = "jordan.user"
        OU         = $UsersOU
        Group      = "Standard-Users"
    },
    @{
        FirstName  = "Taylor"
        LastName   = "Helpdesk"
        SamAccount = "taylor.helpdesk"
        OU         = $ITOU
        Group      = "Helpdesk"
    }
)

foreach ($User in $Users) {

    $ExistingUser = Get-ADUser `
        -Filter "SamAccountName -eq '$($User.SamAccount)'" `
        -ErrorAction SilentlyContinue

    if (-not $ExistingUser) {

        Write-Host ""
        Write-Host "[*] Creating user: $($User.SamAccount)" -ForegroundColor Yellow

        $Password = Read-Host `
            "Enter temporary password for $($User.SamAccount)" `
            -AsSecureString

        New-ADUser `
            -Name "$($User.FirstName) $($User.LastName)" `
            -GivenName $User.FirstName `
            -Surname $User.LastName `
            -SamAccountName $User.SamAccount `
            -UserPrincipalName "$($User.SamAccount)@$($Domain.DNSRoot)" `
            -Path $User.OU `
            -AccountPassword $Password `
            -Enabled $true `
            -ChangePasswordAtLogon $true

        Add-ADGroupMember `
            -Identity $User.Group `
            -Members $User.SamAccount

        Write-Host "[+] Created user: $($User.SamAccount)" -ForegroundColor Green
        Write-Host "[+] Added user to: $($User.Group)" -ForegroundColor Green
    }
    else {
        Write-Host "[=] User already exists: $($User.SamAccount)" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host " Active Directory Setup Complete" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Cyan

Write-Host ""
Write-Host "Lab Users:"

Get-ADUser -Filter * |
    Where-Object {
        $_.SamAccountName -in @(
            "alex.admin",
            "jordan.user",
            "taylor.helpdesk"
        )
    } |
    Select-Object Name, SamAccountName, Enabled |
    Format-Table -AutoSize

Write-Host ""
Write-Host "Lab Security Groups:"

Get-ADGroup -Filter * |
    Where-Object {
        $_.Name -in @(
            "IT-Admins",
            "Helpdesk",
            "Standard-Users"
        )
    } |
    Select-Object Name, GroupScope, GroupCategory |
    Format-Table -AutoSize
