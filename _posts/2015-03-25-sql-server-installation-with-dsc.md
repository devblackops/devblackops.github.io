---
title:  SQL Server Installation with DSC
date:   2015-03-25
featured-image: posts/sql-server-installation-with-dsc/sql-server-logo.png
excerpt: "If you're looking for an example of a SQL Server Installation with DSC then read below."
comments: true
categories: [DSC]
tags: [PowerShell, SQL Server]
---

If you're looking for an example of a SQL Server Installation with DSC then read below.

I'm been playing a lot with DSC lately and specifically with the xSQLServerSetup resource in the [xSQLServer](https://gallery.technet.microsoft.com/xSQLServer-PowerShell-12d76584) module found in the DSC resource kit. In my tests I ran into the same bug detailed here on TechNet:

[https://social.technet.microsoft.com/Forums/en-US/c31314f4-e440-424f-a52e-c8c6e2bf703b/powershell-dsc-xsqlserver-xsqlserversetup-error?forum=ITCG](https://social.technet.microsoft.com/Forums/en-US/c31314f4-e440-424f-a52e-c8c6e2bf703b/powershell-dsc-xsqlserver-xsqlserversetup-error?forum=ITCG)

The specific error is:

>MSFT_xSQLServerSetup failed to execute Set-TargetResource functionality with error message: Set-TargetResouce failed.

I found that SQL was successfully being installed but the Local Configuration Manager was left in a weird state so I used this opportunity to build my own SQL installation module as an exercise for myself. This is in part based on another DSC module by Colin Dembovsky found [here](http://colinsalmcorner.com/post/install-and-configure-sql-server-using-powershell-dsc). This is not intended to replace all the functionality in the xSQLServer module and I expect I will use the xSQLServerSetup resource for production use once it is fully baked. All this module will do is install SQL Server using some basic settings. It will NOT modify or uninstall SQL if you change your DSC configuration after the fact. I had no need for that capability but feel free to extend this if you like.

#### DSC Configuration
{% highlight powershell linenos %}
$computerName = "sql01"
$installCreds = Get-Credential
$saCreds = Get-Credential

$ConfigData = @{   
    AllNodes = @(        
        @{     
            NodeName = "*"
            PSDscAllowPlainTextPassword = $true
        }
        @{
            NodeName = $computerName
            Credentials = $creds
            SQLInstanceName = "MSSQLSERVER"
            SQLFeatures = "SQLENGINE, IS, CONN, BC, SDK, BOL, SSMS, ADV_SSMS"
            SQLSecurityMode = "SQL"
            SQLISOSourcePath = "<<PATH TO SQL ISO>>"
            SACredentials = $saCreds
        }
    )  
}

Configuration SQLInstallTest {
    param ()

    Import-DscResource -ModuleName cSQLInstaller

    Node $AllNodes.NodeName {          
        cscSQLInstaller InstallSQL {
            Name = "BaseSQLInstall"
            Ensure = "Present"
            SQLISOSourcePath = $Node.SQLISOSourcePath
            SetupCredentials = $Node.Credentials
            SecurityMode = $Node.SQLSecurityMode
            SAPwd = $Node.SACredentials
        }
    }
}
{% endhighlight %}

#### Custom SQL Install Resource

{% highlight powershell linenos %}
function Get-TargetResource {
  [CmdletBinding()]
  [OutputType([System.Collections.Hashtable])]
  param (
    [parameter(Mandatory = $true)]
    [System.String]
    $Name,

    [parameter(Mandatory = $true)]
    [ValidateSet("Present","Absent")]
    [System.String]
    $Ensure,

    [parameter(Mandatory = $true)]
    [System.String]
    $SQLISOSourcePath,

    [parameter(Mandatory = $true)]
    [System.Management.Automation.PSCredential]
    $SetupCredentials,

    [parameter(Mandatory = $true)]
    [ValidateSet("SQL","Windows")]
    [System.String]
    $SecurityMode
  )

  # Get SQL instances
  $sqlInstances = gwmi win32_service -computerName localhost | ? { $_.Name -match "mssql*" -and $_.PathName -match "sqlservr.exe" } | % { $_.Caption }
  $res = $sqlInstances -ne $null -and $sqlInstances -gt 0
  $vals = @{
    Installed = $res;
    InstanceCount = $sqlInstances.count
  }
  $vals
}


function Set-TargetResource {
  [CmdletBinding()]
  param (
    [parameter(Mandatory = $true)]
    [System.String]
    $Name,

    [parameter(Mandatory = $true)]
    [ValidateSet("Present","Absent")]
    [System.String]
    $Ensure,

    [System.String]
    $Features = "SQLENGINE,IS,CONN,BC,SDK,BOL,SSMS,ADV_SSMS",

    [System.String]
    $InstanceName = "MSSQLSERVER",

    [System.String]
    $InstanceDir = "D:\MSSQL",

    [System.String]
    $SQLCollation = "Latin1_General_100_CI_AS_KS_WS_SC",

    [System.String]
    $SQLUserDBDir = "D:\MSSQL\Data",

    [System.String]
    $SQLUserDBLogDir = "L:\MSSQL\Data",

    [System.String]
    $SQLTempDBDir = "T:\MSSQL\Data",

    [System.String]
    $SQLTempDBLogDir = "V:\MSSQL\Data",

    [System.String]
    $SQLBackupDir = "D:\MSSQL\Backups",

    [parameter(Mandatory = $true)]
    [System.String]
    $SQLISOSourcePath,

    [parameter(Mandatory = $true)]
    [System.Management.Automation.PSCredential]
    $SetupCredentials,

    [parameter(Mandatory = $true)]
    [ValidateSet("SQL","Windows")]
    [System.String]
    $SecurityMode,

    [System.Management.Automation.PSCredential]
    $SAPwd,

    [System.Management.Automation.PSCredential]
    $SQLSvcAccount,

    [System.Management.Automation.PSCredential]
    $AgtSvcAccount
  )

  if ($Ensure -eq "Present") {
    #region Copy and mount ISO
    $localISOPath = (Join-Path -Path $env:SystemDrive -ChildPath "Temp")
    Write-Verbose "Copying SQL ISO locally"                
    $localISOFullPath = Copy-Item -Path $SQLISOSourcePath -Destination $localISOPath -Force -PassThru

    Write-Verbose "Mounting SQL ISO file"
    $setupDriveLetter = (Mount-DiskImage -ImagePath $localISOFullPath -PassThru | Get-Volume).DriveLetter + ":"
    if ($setupDriveLetter -eq $null) {
      throw "Could not mount SQL install iso"
    }
    Write-Verbose "Drive letter for ISO is: $setupDriveLetter"
    #endregion

    #region Build install arguments
    $arguments = " /Quiet=`"True`" /IAcceptSQLServerLicenseTerms=`"True`" /Enu=`"True`" /UpdateEnabled=`"True`" /UpdateSource=`"MU`" /ErrorReporting=`"False`" /Action=`"Install`""
    $arguments += " /Help=`"False`" /IndicateProgress=`"False`" /x86=`"False`" /InstallSharedDir=`"C:\Program Files\Microsoft SQL Server`" /InstallSharedWoWDir=`"C:\Program Files (x86)\Microsoft SQL Server`" "
    $arguments += " /InstanceName=`"$InstanceName`" "
    $arguments += " /Features=`"" + $Features + "`" /SQMReporting=`"False`" /InstanceID=`"MSSQLSERVER`" /SQLCollation=`"$SQLCollation`" "

    # SQLSvcAccount
    if($PSBoundParameters.ContainsKey("SQLSvcAccount")) {
      if($SQLSvcAccount.UserName -eq "SYSTEM") {
        $arguments += " /SQLSVCACCOUNT=`"NT AUTHORITY\SYSTEM`""
      } else {
        $arguments += " /SQLSVCACCOUNT=`"" + $SQLSvcAccount.UserName + "`""
        $arguments += " /SQLSVCPASSWORD=`"" + $SQLSvcAccount.GetNetworkCredential().Password + "`""
      }
    }

    # AgtSvcAccount
    if($PSBoundParameters.ContainsKey("AgtSvcAccount")) {
      if($AgtSvcAccount.UserName -eq "SYSTEM") {
        $arguments += " /AGTSVCACCOUNT=`"NT AUTHORITY\SYSTEM`" "
      } else {
        $arguments += " /AGTSVCACCOUNT=`"" + $AgtSvcAccount.UserName + "`""
        $arguments += " /AGTSVCPASSWORD=`"" + $AgtSvcAccount.GetNetworkCredential().Password + "`""
      }
    }
    $arguments += " /AGTSVCSTARTUPTYPE=Automatic "

    # SQLSysAdminAccounts
    $arguments += " /SQLSysAdminAccounts=`"" + $SetupCredentials.UserName + "`""
    if($PSBoundParameters.ContainsKey("SQLSysAdminAccounts")) {
      foreach($AdminAccount in $SQLSysAdminAccounts) {
        $arguments += " `"$AdminAccount`""
      }
    }

    # SAPwd
    if($SecurityMode -eq "SQL") {
      $arguments += " /SecurityMode=`"SQL`" "
      $arguments += " /SAPwd=" + "'" + $SAPwd.GetNetworkCredential().Password + "'"
    }        
    #endregion

    #region Run the installer using arguments
    Write-Verbose  $arguments
    $cmd = "$setupDriveLetter\Setup.exe " + $arguments
    Write-Verbose "Running SQL Install - check %programfiles%\Microsoft SQL Server\120\Setup Bootstrap\Log\ for logs..."
    Invoke-Expression $cmd | Write-Verbose
    #endregion

    #region Finish
    Write-Verbose "Dismounting SQL ISO"
    Dismount-DiskImage -ImagePath $localISOFullPath
    Write-Verbose "Removing install files"
    Remove-Item $localISOFullPath -Force
    #endregion
  }
}


function Test-TargetResource {
  [CmdletBinding()]
  [OutputType([System.Boolean])]
  param (
    [parameter(Mandatory = $true)]
    [System.String]
    $Name,

    [parameter(Mandatory = $true)]
    [ValidateSet("Present","Absent")]
    [System.String]
    $Ensure,

    [System.String]
    $Features = "SQLENGINE,IS,CONN,BC,SDK,BOL,SSMS,ADV_SSMS",

    [System.String]
    $InstanceName = "MSSQLSERVER",

    [System.String]
    $InstanceDir = "D:\MSSQL",

    [System.String]
    $SQLCollation = "Latin1_General_100_CI_AS_KS_WS_SC",

    [System.String]
    $SQLUserDBDir = "D:\MSSQL\Data",

    [System.String]
    $SQLUserDBLogDir = "L:\MSSQL\Data",

    [System.String]
    $SQLTempDBDir = "T:\MSSQL\Data",

    [System.String]
    $SQLTempDBLogDir = "V:\MSSQL\Data",

    [System.String]
    $SQLBackupDir = "D:\MSSQL\Backups",

    [parameter(Mandatory = $true)]
    [System.String]
    $SQLISOSourcePath,

    [parameter(Mandatory = $true)]
    [System.Management.Automation.PSCredential]
    $SetupCredentials,

    [parameter(Mandatory = $true)]
    [ValidateSet("SQL","Windows")]
    [System.String]
    $SecurityMode,

    [System.Management.Automation.PSCredential]
    $SAPwd,

    [System.Management.Automation.PSCredential]
    $SQLSvcAccount,

    [System.Management.Automation.PSCredential]
    $AgtSvcAccount
  )

  $sqlInstances = gwmi win32_service -computerName localhost | ? { $_.Name -match "mssql*" -and $_.PathName -match "sqlservr.exe" } | % { $_.Caption }
  $res = $sqlInstances -ne $null -and $sqlInstances -gt 0
  if ($res) {
    Write-Verbose "SQL Server is already installed"
  } else {
    Write-Verbose "SQL Server is not installed"
  }
  $res
}


Export-ModuleMember -Function *-TargetResource
{% endhighlight %}

Cheers,

Brandon
