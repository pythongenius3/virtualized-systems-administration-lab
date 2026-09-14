# Virtualized Systems Administration Lab Notes

## Environment

### Domain Controller

**Hostname**

```text
LAB-DC01
**Operating System**

```text
Windows Server
```
**IP Address**

```text
192.168.56.10
```
**Subnet Mask**

```text
255.255.255.0
```
**DNS**

```text
192.168.56.10
```
**Domain**

```text
lab.local
```
---

### Windows Client

**Hostname**

```text
LAB-CLIENT01
```
**Operating System**

```text
Windows 10 / Windows 11
```
**IP Address**

```text
192.168.56.20
```
**DNS Server**

```text
192.168.56.10
```
**Domain**

```text
lab.local
```
---

# Deployment Checklist

## VirtualBox

- [ ] Install VirtualBox
- [ ] Download Windows Server ISO
- [ ] Download Windows client ISO
- [ ] Create Windows Server VM
- [ ] Create Windows client VM
- [ ] Configure both VMs on the same isolated network
## Windows Server

- [ ] Install Windows Server
- [ ] Rename server to LAB-DC01
- [ ] Configure static IP address
- [ ] Configure DNS
- [ ] Install Active Directory Domain Services
- [ ] Promote server to Domain Controller
- [ ] Create lab.local domain
- [ ] Verify DNS
- [ ] Create Organizational Units
- [ ] Create security groups
- [ ] Create test users
- [ ] Configure Group Policy
## Windows Client

- [ ] Install Windows
- [ ] Rename workstation to LAB-CLIENT01
- [ ] Configure IP address
- [ ] Configure DNS as 192.168.56.10
- [ ] Verify server connectivity
- [ ] Verify DNS resolution
- [ ] Join lab.local
- [ ] Restart workstation
- [ ] Sign in using a domain account
- [ ] Move computer into Workstations OU
- [ ] Run `gpupdate /force`
- [ ] Verify Group Policy
---

# PowerShell Script Order

Run the scripts in this order:

```text
01-install-ad-ds.ps1
02-create-ad-structure.ps1
03-configure-gpo.ps1
06-join-client.ps1
04-audit-system.ps1
05-domain-health.ps1
```

`01` through `05` are primarily intended for the Windows Server VM.

`06-join-client.ps1` runs on the Windows client VM.
---

# Troubleshooting Log

Use this section to document real problems encountered while building the lab.

## Issue

Describe the problem.

## Symptoms

Document what you observed.

## Initial Hypothesis

State what you think might be causing the issue.

## Diagnostic Tools

Examples:

```text
ipconfig /all
nslookup
Resolve-DnsName
ping
Test-NetConnection
Event Viewer
---

# Evidence Checklist

Capture screenshots of the completed environment:

- [ ] VirtualBox VM configuration
- [ ] Windows Server desktop
- [ ] Static IP configuration
- [ ] Server Manager
- [ ] Active Directory Users and Computers
- [ ] Organizational Units
- [ ] Security Groups
- [ ] Test user accounts
- [ ] DNS Manager
- [ ] Group Policy Management
- [ ] Lab Workstation Baseline GPO
- [ ] Windows client domain membership
- [ ] Domain user login
- [ ] PowerShell script output
- [ ] System audit output
- [ ] Windows Event Viewer
- [ ] Troubleshooting scenario
