---
title:  Find Potentially Orphaned VM Snapshots
date:   2015-03-19
categories: [PowerShell, VMware]
featured-image: posts/find-potentially-orphaned-vm-snapshots/ghostbusters.gif
excerpt: "Here is a quick function to find potentially orphaned VMs snapshots. This basically looks for VMs with active snapshots using Get-Snapshot and compares that to a list of VMs where the disk file name matches *-*000*.vmdk."
comments: true
tags: [PowerShell, Snapshots, VMware]
---

Here is a quick function to find potentially orphaned VMs snapshots. This basically looks for VMs with active snapshots using Get-Snapshot and compares that to a list of VMs where the disk file name matches *-*000*.vmdk. I've seen problems (particularly with backup software) leaving these snapshot disks around after a VM backup terminates abnormally. This could lead to unplanned storage utilization on your array and potentially filling up the datastore(s). That's bad

``` powershell
function Find-VMsWithOrphanedSnapshots {
  <#
    .Synopsis
      Finds potentially orphaned snapshot disks on VMs.
    .Example
      Find-VMsWithOrphanedSnapshots "vcenter01", "vcenter02"
    .Parameter vCenters
      A string array of vCenters to connec to.    
    .Notes
      NAME: Find-VMsWithOrphanedSnapshots
      VERSION: 1.1
      AUTHOR: Brandon Olin
      LASTEDIT: 3/19/2015
      KEYWORDS: VM, Snapshot, Disk
    .Link
      http://devblackops.io
    #Requires -Version 2.0
  #>

  [cmdletbinding()]
  Param(
    [ValidateNotNullOrEmpty()]
    [String[]]$vCenters
  )

  If ((Get-PSSnapin "VMware.VimAutomation.Core" -ea SilentlyContinue) -eq $null) {
    Write-Verbose "Adding VMware snapin..."
    Add-PSSnapin VMware.VimAutomation.Core
  }

  foreach($vCenter in $vCenters) {
    Write-Verbose "Connecting to vCenter: $vCenter"
    Connect-VIServer $vcenter -verbose:$false | out-null
  }

  Write-Verbose "Getting VMs..."
  $VMs = Get-VM -verbose:$false
  Write-Verbose "Found $($VMs.count) VMs"

  $VMsWithSnapshots = @()
  Write-verbose "Getting snapshots..."
  $snapshots = $VMs | Get-Snapshot -verbose:$false
  $snapshots | % {
    $VMsWithSnapshots += $_.VM.Name
  }
  $VMsWithSnapshots = $VMsWithSnapshots | Sort
  Write-Verbose "Found $($VMsWithSnapshots.count) snapshots"

  $VMsWithSnapshotDisks = @()
  $vmDisks = @()
  Write-Verbose "Getting all VM disks. This may take some time..."
  $VMs | Get-HardDisk -Verbose:$false | % {
    $tmp = "" | Select VM, FileName
    $tmp.VM = $_.Parent.Name
    $tmp.FileName = $_.FileName
    $vmDisks += $tmp
  }
  $snapshotDisks = $vmDisks | ? {$_.Filename -like '*-*000*.vmdk'}
  $snapshotDisks | Group VM | % {
    $VMsWithSnapshotDisks += $_.Name
  }
  $VMsWithSnapshotDisks = $VMsWithSnapshotDisks | Sort
  Write-Verbose "Found $($VMsWithSnapshotDisks.Count) VMs with active snapshots"

  $result = @()
  foreach ($VM in $VMsWithSnapshotDisks) {
    if ($VMsWithSnapshots -notcontains $VM) {			
      $tmp = "" | Select VM, Disks
      $tmp.VM = $VM
      $tmp.Disks = $vmDisks | ? {$_.VM -eq $VM} | Select FileName					
      $result += $tmp
    }
  }
  Write-Verbose "Found $($result.Count) VMs with potentially orphaned snapshots"

  return $result
}
```
