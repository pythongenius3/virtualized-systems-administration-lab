# Virtualized Systems Administration Lab

## Overview

This project is a hands-on Windows systems administration lab designed to simulate a small enterprise IT environment using virtualization.

The lab uses Windows Server, Active Directory Domain Services (AD DS), DNS, Group Policy, PowerShell, and a domain-joined Windows workstation to practice common systems administration tasks.

> **Project Status:** In Progress

## Lab Architecture

```text
                    VirtualBox
                        |
               Internal Network
                        |
             +----------+----------+
             |                     |
      Windows Server VM      Windows Client VM
             |                     |
        Domain Controller       Domain Joined
             |
        +----+----+
        |         |
      AD DS       DNS
        |
   +----+----------------+
   |         |           |
 Users     Groups       OUs
```

## Technologies

- Windows Server
- Windows 10/11
- Oracle VirtualBox
- Active Directory Domain Services
- DNS
- Group Policy
- PowerShell
- Windows Event Viewer
- Windows Defender Firewall
- TCP/IP Networking

## Planned Environment

| System | Role | IP Address |
|---|---|---|
| LAB-DC01 | Domain Controller / DNS | 192.168.56.10 |
| LAB-CLIENT01 | Domain Workstation | 192.168.56.20 |

**Domain:** `lab.local`

**NetBIOS Domain:** `LAB`

## Project Objectives

- Deploy Windows Server in VirtualBox
- Install Active Directory Domain Services
- Configure DNS
- Create Organizational Units
- Create users and security groups
- Configure Group Policy
- Join a Windows workstation to the domain
- Automate administrative tasks with PowerShell
- Audit Windows system configuration
- Review Windows Event Logs
- Perform domain controller health checks
- Troubleshoot DNS and domain connectivity issues
- Document troubleshooting procedures

## PowerShell Automation

The `scripts` directory will contain:

1. Active Directory deployment
2. Active Directory structure creation
3. Group Policy configuration
4. Windows system auditing
5. Domain controller health checks
6. Windows client domain joining

## Skills Demonstrated

- Windows Server Administration
- Active Directory
- DNS
- Group Policy
- PowerShell
- Windows Administration
- Virtualization
- TCP/IP Networking
- Identity and Access Management
- System Troubleshooting
- Event Log Analysis
- Technical Documentation

## Security

This project is built strictly in an isolated personal lab environment.

No employer data, production credentials, passwords, API keys, proprietary documentation, or sensitive information will be stored in this repository.
