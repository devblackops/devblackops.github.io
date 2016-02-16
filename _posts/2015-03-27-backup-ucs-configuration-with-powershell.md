---
title:  Backup UCS configuration with PowerShell
date:   2015-03-27
featured-image: posts/idea-for-vmware-provisioning-with-dsc/vmware_plus_powershell.png
excerpt: "If you're in a situation where you need to backup your UCS configuration with PowerShell then continue reading. Below you will see how you can schedule a PowerShell script to backup all the UCS Manager configurations in your environment and save them to a SMB share."
comments: true
categories: [DevOps, DSC, PowerShell, VMware]
tags: [DSC, PowerShell, VMware]
---

If you're in a situation where you need to backup your UCS configuration with PowerShell then continue reading. Below you will see how you can schedule a PowerShell script to backup all the UCS Manager configurations in your environment and save them to a SMB share.

This script relies on the following two PowerShell modules in order to function.

### Cisco UCS PowerTool

You can download the UCS PowerTool module [here](https://software.cisco.com/download/release.html?mdfid=286282669&flowid=72562&softwareid=284574017&release=1.3(1)&relind=AVAILABLE&rellifecycle=&reltype=latest). This is an awesome module provided by Cisco and has a TON of cmdlets. It's safe to say that for anything you want to do in UCS, there is probably a cmdlet available.

![Cisco PowerTool cmdlet count](/images/posts/backup-ucs-configuration-with-powershell/cisco_pscmd_count.png)

### Import / Export PS Credentials module

I've written about this handy module [here](http://devblackops.io/import-export-powershell-credentials-module/). You use this to securely export the PS credentials needed in order to authenticate to your UCS Managers without having to expose any sensitive credentials in plain text.

These credentials can only be read by the user who exported them. This means that if you want to schedule this script via the task scheduler, then you must create and export the credentials as the user that the scheduled task will run under. I my case I use a domain service account.

### Setup

1. Log into the Windows box that will be running the scheduled task.
2. Create your credentials that have access to UCS Manager and export said credentials to the same folder that you've placed the script is in.

![Export PowerShell credentials to .xml file.](/images/posts/backup-ucs-configuration-with-powershell/ucs_export_creds.png)

3. Create a text file called "UCS Managers.txt" in the same folder. Enter the FQDN of each UCS Manager instance that your want to backup on a new line.
4. Schedule the script via the task scheduler to under under the same service account that you are exported the credentials with.
5. Your folder should look like this:

![UCS config backup folder](/images/posts/backup-ucs-configuration-with-powershell/backup_ucs_config_folder.png)

### Script

{% highlight powershell linenos  %}
Import-Module -Name 'C:\Program Files\Cisco\Cisco UCS PowerTool\CiscoUcsPS.psd1'
Import-Module -Name Credentials

$basePath = 'C:\Scripts\Backup_UCS_Config'
$backupPath = '\\NASSERVER\Backup\UCS'
$UCSManagers = Get-Content ($basePath + '\UCS Managers.txt')
$creds = Import-PSCredential ($basePath + '\creds.xml')

#Connect to UCS
$handles = @()
$UCSManagers | ForEach-Object -Process {
  Write-Output -Object "Connecting to $_"
  $handles += Connect-Ucs -Name $_ -Credential $creds -NotDefault
}

#Backup configuration
$handles | ForEach-Object -Process {
  $ucsName = $_.Name
  Write-Output -Object ("Backing up full state for UCS $ucsName")
  Backup-Ucs -Type full-state -PathPattern ($basePath + '\${ucs}-${yyyy}${MM}${dd}-${HH}${mm}-full-state.xml') -Ucs $_
  Write-Output -Object ("Backing up logical config for UCS $ucsName")
  Backup-Ucs -Type config-logical -PathPattern ($basePath + '\${ucs}-${yyyy}${MM}${dd}-${HH}${mm}-config-logical.xml') -Ucs $_
  Write-Output -Object ("Backing up system config for UCS $ucsName")
  Backup-Ucs -Type config-system -PathPattern ($basePath + '\${ucs}-${yyyy}${MM}${dd}-${HH}${mm}-config-system.xml') -Ucs $_
  Write-Output -Object ("Backing up full config for UCS $ucsName")
  Backup-Ucs -Type config-all -PathPattern ($basePath + '\${ucs}-${yyyy}${MM}${dd}-${HH}${mm}-config-all.xml') -Ucs $_
}

#Disconnect from UCS
$handles | ForEach-Object -Process {
  Write-Output -Object "Disconnecting from $_"
  Disconnect-Ucs -Ucs $_
}

#Move backups to backup location
Write-Output -Object "Moving backups to $backuPath"
Get-ChildItem $basePath | Where-Object -FilterScript {$_.Name -match 'UC*.*xml'} | Move-Item -Destination $backupPath -Force

{% endhighlight %}
