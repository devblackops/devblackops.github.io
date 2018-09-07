---
title:  VMware Provisioning with PowerShell DSC
date:   2015-04-10
featured-image: posts/vmware-provisioning-with-powershell-dsc/vmware_plus_powershell.png
excerpt: I've written about the idea of [VMware Provisioning with PowerShell DSC before and now I want to show how you can accomplish this using a working example.
  Below is an admittedly basic but functional custom DSC module to deploy VMs using VMware's PowerCLI.
comments: true
categories: [DevOps, DSC, PowerShell, VMware]
tags: [DevOps, DSC, PowerShell, VMware]
---

>UPDATE - I've started a series of posts about POSHOrigin.
A PowerShell module and DSC resource that takes this to the next level.
Check it out [here](http://devblackops.io/poshorigin-part-1-summary/){:target="_blank"}.

I've written about the idea of [VMware Provisioning with PowerShell DSC](http://devblackops.io/vmware-provisioning-with-dsc/) before and now I want to show how you can accomplish this using a working example.
Below is an admittedly basic but functional custom DSC module to deploy VMs using VMware's [PowerCLI](https://www.vmware.com/support/developer/PowerCLI/).I plan on continuing to add features to this DSC module that enhance VM provisioning and configuration, adding some helper cmdlets for working with DSC, as well as create additional custom DSC resources for the following:

1. Virtual Datacenter creation
2. Cluster creation
  * DRS configuration
  * HA configuration
3. Datastore creation / configuration
4. Network creation
5. Others? Let me know here

### Get It

Download the module from [GitHub](https://github.com/devblackops/POSHOrigin_vSphere). All comments and contributions are welcome.

### Requirements

1. [Windows Management Framework 5](http://www.microsoft.com/en-us/download/details.aspx?id=45883) - This module is built using DSC classes which are only available as part of PowerShell 5. WMF 5 is still in preview so think carefully if you want to use this in production.
2. [PowerCLI](https://www.vmware.com/support/developer/PowerCLI/) - I am currently using version 6.0 Release 1 but I believe any recent version of PowerCLI will work. Note that I have not tested any other version with this.
3. Provisioning server - This is the Windows system where PowerCLI will need to be installed and is the target for your DSC configuration. I recommend this be separate from your DSC pull server.

### Example Configuration

Below is an example DSC configuration for defining two VMs to be deployed from a given template and ensuring vCPU and RAM match the configuration.

>Please note that this is storing vCenter credentials in **PLAIN TEXT** in the DSC configuration. **DO NOT DO THIS IN ANYTHING BUT A SANDBOX ENVIRONMENT**. For a good overview of setting up certificates with DSC please check [here](http://blogs.msdn.com/b/powershell/archive/2014/01/31/want-to-secure-credentials-in-windows-powershell-desired-state-configuration.aspx).

{% highlight powershell linenos %}
$provisioningServer = 'SERVER01'
$vCenterCreds = Get-Credential -Message 'Enter vCenter credentials'

$ConfigData = @{
    AllNodes = @(
        @{
            NodeName = "*"
            PSDscAllowPlainTextPassword = $true
        }
        @{
            NodeName = $provisioningServer
            Config = @(
                @{
                    Credentials = $vCenterCreds
                    VMName = 'vm01'
                    vCenter = 'vcenter01.local'
                    VMTemplate = 'W2K12R2_Std'
                    TotalvCPU = 2
                    CoresPerSocket = 1
                    vRAM = 4
                    Datacenter = 'Datacenter01'
                    Cluster = 'Workload'
                    InitialDatastore = 'datastore01'
                },
                @{
                    Credentials = $vCenterCreds
                    VMName = 'vm02'
                    vCenter = 'vcenter01.local'
                    VMTemplate = 'W2K12R2_Std'
                    TotalvCPU = 8
                    CoresPerSocket = 2
                    vRAM = 8
                    Datacenter = 'Datacenter01'
                    Cluster = 'Workload'
                    InitialDatastore = 'datastore01'
                }
            )
        }
    )
}

enum Ensure {
   Absent
   Present
}

Configuration TestVMDeploy {
    param ()

    Import-DscResource -ModuleName cVMware
    cls
    Node $AllNodes.NodeName {
        $Node.Config | % {
            Write-Host "Creating VM configuration for: $($_.VMName)"
            cVMwareVM $_.VMName {
                Ensure = [Ensure]::Present
                VMName = $_.VMName
                vCenter = $_.vCenter
                VMTemplate = $_.VMTemplate
                Credentials = $_.Credentials
                TotalvCPU = $_.TotalvCPU
                CoresPerSocket = $_.CoresPerSocket
                vRAM = $_.vRAM
                Datacenter = $_.Datacenter
                Cluster = $_.Cluster
                InitialDatastore = $_.InitialDatastore
                DiskSpec = $_.DiskSpec
            }
        }
    }
}

$guid = [guid]::Parse('e7f0b61a-b833-466d-afc8-daf043ab8b9f')
$source = TestVMDeploy -ConfigurationData $ConfigData
$target = "C:\Program Files\WindowsPowerShell\DscService\Configuration\$Guid.mof"
copy $source $target
New-DSCCheckSum $target -Force
{% endhighlight %}

### DSC Creating the VMs

Once the DSC configuration is run and applied to the pull server. Run **Update-DscConfiguration -Wait -Verbose** on the provisioning node to kick off the DSC run. Here you can see it checking for the existence of the two VMs and creating them.

![DSC VM Deploy](/images/posts/vmware-provisioning-with-powershell-dsc/dsc_vm_deploy.png)

Here we will run the configuration again. This time it will find the two VMs but notice that the vCPU configuration doesn't match the desired state. This is because the VMs were deployed from a template and the vCPU configuration defined in DSC does not match what the template was configured for.

![DSC VM Change CPU](/images/posts/vmware-provisioning-with-powershell-dsc/dsc_vm_change_cpu.png)

### Changing Resource Requirements in Configuration

Let's change the memory requirements for the two VMs. We only need to change the vRAM parameter in the configuration data and rerun the configuration.

{% highlight powershell linenos %}
$ConfigData = @{
    AllNodes = @(
        @{
            NodeName = "*"
            PSDscAllowPlainTextPassword = $true
        }
        @{
            NodeName = $provisioningServer
            Config = @(
                @{
                    Credentials = $vCenterCreds
                    VMName = 'vm01'
                    vCenter = 'vcenter01.local'
                    VMTemplate = 'W2K12R2_Std'
                    TotalvCPU = 2
                    CoresPerSocket = 1
                    vRAM = 2
                    Datacenter = 'Datacenter01'
                    Cluster = 'Workload'
                    InitialDatastore = 'datastore01'
                },
                @{
                    Credentials = $vCenterCreds
                    VMName = 'vm02'
                    vCenter = 'vcenter01.local'
                    VMTemplate = 'W2K12R2_Std'
                    TotalvCPU = 8
                    CoresPerSocket = 2
                    vRAM = 10
                    Datacenter = 'Datacenter01'
                    Cluster = 'Workload'
                    InitialDatastore = 'datastore01'
                }
            )
        }
    )
}
{% endhighlight %}

### Results of Change

![DSC VM Change vRAM](/images/posts/vmware-provisioning-with-powershell-dsc/dsc_vm_change_vram.png)
![DSC VM Change vRAM vCenter view](/images/posts/vmware-provisioning-with-powershell-dsc/dsc_vm_change_vram_vcenter_view.png)

### DSC Resource

Here is the full DSC resource and module manifest.

{% highlight powershell linenos  %}
enum Ensure {
   Absent
   Present
}

[DscResource()]
class cVMwareVM {
    [DscProperty(key)]
    [string]$VMName

    [DscProperty(Mandatory)]
    [pscredential]$Credentials

    [DscProperty(Mandatory)]
    [int]$TotalvCPU

    [DscProperty(Mandatory)]
    [int]$CoresPerSocket

    [DscProperty(mandatory)]
    [int]$vRAM

    [DSCProperty()]
    [string]$DiskSpec

    [DSCProperty()]
    [string]$VMTemplate

    [DscProperty(mandatory)]
    [string]$vCenter

    [DscProperty(Mandatory)]
    [string]$Datacenter

    [DscProperty(Mandatory)]
    [string]$InitialDatastore

    [DscProperty()]
    [string]$Cluster

    [DscProperty()]
    [string]$VMHost

    [DscProperty(mandatory)]
    [Ensure]$Ensure

    [bool]$vCenterConnected

    [cVMwareVM]Get() {
        $vmConfig = [hashtable]::new()
        $vmConfig.Add('VMName', $this.VMName)
        $vmConfig.Add('Credentials', $this.Credentials)
        $vmConfig.Add('TotalvCPU', $this.TotalvCPU)
        $vmConfig.Add('CoresPerSocket', $this.CoresPerSocket)
        $vmConfig.Add('vRAM', $this.vRAM)
        $vmConfig.Add('DiskSpec', $this.DiskSpec)
        $vmConfig.Add('VMTemplate', $this.VMTemplate)
        $vmConfig.Add('vCenter', $this.vCenter)
        $vmConfig.Add('Datacenter', $this.Datacenter)
        $vmConfig.Add('InitialDatastore', $this.InitialDatastore)
        $vmConfig.Add('Cluster', $this.VMCluster)
        $vmConfig.Add('VMHost', $this.VMHost)
        $vmConfig.Add('Ensure', $this.Ensure)

        # Connect to vCenter
        if (!$this.vCenterConnected) { $this.ConnectTovCenter() }

        $vm = FindVM -Name $this.VMName

        try {
            if ($vm -ne $null) {
                $vmConfig.Add('Ensure','Present')
                $vmConfig.Add('vRAM', $vm.MemoryGB)
            } else {
                $vmConfig.Add('Ensure','Absent')
            }
        } catch {
            $exception = $_
            Write-Verbose 'Error occurred'
            while ($exception.InnerException -ne $null) {
                $exception = $exception.InnerException
                Write-Verbose $exception.message
            }
        }
        return $vmConfig
    }

    [void]Set() {
        try {

            if (!$this.vCenterConnected) { $this.ConnectTovCenter() }

            if ($this.Ensure -eq [Ensure]::Present) {

                $vm = Get-VM -Name $this.VMName -verbose:$false -ErrorAction SilentlyContinue | select -First 1

                if ($vm -eq $null) {
                    Write-Verbose "Creating VM: $($this.VMName)"
                    $result = $this.CreateVM()
                    if ($result -eq $true) {
                        Write-Verbose 'VM created successfully'
                    } else {
                        throw 'There was a problem creating the VM'
                    }
                } else {
                    # vRAM
                    if ($vm.MemoryGB -ne $this.vRAM) {
                        # It is safe to decrease vRAM is VM is powered off
                        if ($vm.PowerState -eq 'PoweredOn') {
                            # Are we increasing vRAM?
                            if ($vm.MemoryGB -lt $this.vRAM) {
                                write-verbose "Changing $($this.VMName) vRAM to $($this.vRAM)"
                                set-vm -vm $vm -memorygb $($this.vRAM) -confirm:$false -verbose:$false
                            } else {
                                write-error 'Cannot decrease vRAM while VM is powered on'
                            }
                        } else {
                            write-verbose "Changing $($this.VMName) vRAM to $($this.vRAM)"
                            set-vm -vm $vm -memorygb $($this.vRAM) -confirm:$false -verbose:$false
                        }
                    }

                    # VM matches CPU
                    if (($vm.extensiondata.config.hardware.numcpu -ne $this.TotalvCPU) -or ($vm.extensiondata.config.hardware.numcorespersocket -ne $this.CoresPerSocket)) {

                        if ($vm.PowerState -eq 'PoweredOn') {
                            # IS CPU hotadd enabled?
                            if ($VM.extensiondata.config.cpuhotaddenabled) {

                            } else {
                                write-error 'CPU hotadd is disabled on this VM. Cannot increase vCPU while VM is powered on'
                            }
                        } else {
                            # Safe to change vCPU while powerd off
                            write-verbose  "Changing $($this.VMName) vCPU to $($this.TotalvCPU)"
                            $this.SetCPU($vm)
                        }
                    }
                }
            } else {
                Write-Verbose "Removing VM: $($this.VMName)"
            }
        } catch {
            Write-Verbose 'There was a problem setting the resource'
            Write-Verbose "$($_.InvocationInfo.ScriptName)($($_.InvocationInfo.ScriptLineNumber)): $($_.InvocationInfo.Line)"
        }
    }

    [bool]Test() {

        $checksPassed = $true

        try {
            if (!$this.vCenterConnected) { $this.ConnectTovCenter() }

            $vm = Get-VM -Name $this.VMName -verbose:$false -ErrorAction SilentlyContinue | select -First 1

            #region Go through checks to determine if resource matches desired state

            # VM exists
            if ($vm -ne $null) {
                Write-Verbose -Message "VM: $($this.VMName) was found"
            } else {
                Write-Verbose -Message "VM: $($this.VMName) was not found"
            }
            if ($this.Ensure -eq [Ensure]::Present) {
                if ($vm -eq $null) { return $false }
            } else {
                if ($vm -eq $null) { return $true } else { return $false }
            }

            # VM matches memory
            if ($vm.MemoryGB -ne $this.vRAM) {
                write-verbose "$($this.VMName) does not match desired vRAM allocation"
                $checksPassed = $false
            }

            # VM matches CPU
            if (($vm.extensiondata.config.hardware.numcpu -ne $this.TotalvCPU) `
                -or ($vm.extensiondata.config.hardware.numcorespersocket -ne $this.CoresPerSocket)) {

                write-verbose "$($this.VMName) does not match desired vCPU allocation"
                $checksPassed = $false
            }

            if ($checksPassed -eq $true) {
                Write-Verbose 'Checks passed'
                return $true
            } else {
                Write-Verbose 'Checks did not pass'
                return $false
            }
            #endregion
        } catch {
            Write-Verbose 'There was a problem testing the resource'
            Write-Verbose "$($_.InvocationInfo.ScriptName)($($_.InvocationInfo.ScriptLineNumber)): $($_.InvocationInfo.Line)"
            return $false
        }
    }

    #region Helpers
    [bool]ConnectTovCenter() {
        if (!$this.vCenterConnected) {
            if ((Get-PSSnapin -Registered -Name 'VMware.VimAutomation.Core') -ne $null) {
                try {
                    Add-PSSnapin 'VMware.VimAutomation.Core'
                    Write-Debug 'Added VMware.VimAutomation.Core snapin'
                } catch {
                    throw 'There was a problem loading snapin Vmware.VimAutomation.Core.'
                }
            } else {
                throw 'Vmware.VimAutmation.Core snapin is not installed on this system!'
            }

            try {
                write-Debug "trying to connect to $($this.vCenter)"
                Connect-VIServer -Server $($this.vCenter) `
                                 -User $($this.Credentials.UserName) `
                                 -Password $($this.Credentials.GetNetworkCredential().Password) `
                                 -Force -verbose
                write-Debug "Connected to vCenter: $($this.vCenter)"
                $this.vCenterConnected = $true
                return $true
            } catch {
                throw "There was a problem connecting to vCenter: $($this.vCenter)"
                $this.vCenterConnected = $false
                return $false
            }
        }
    }

    [bool]FindVM([string]$vmName) {
        if (!$this.vCenterConnected) { ConnectTovCenter }

        write-verbose "Trying to find VM: $vmName"
        $vm = Get-VM -Name $vmName -verbose:$false -ErrorAction SilentlyContinue
        if ($vm -ne $null) {
            return $true
        } else {
            return $false
        }
    }

    [bool]CreateVM() {
        $template = $null
        $cluster = $null
        $datastore = $null

        if ($this.VMTemplate -ne $null) {
            $template = Get-Template -Name $this.VMTemplate `
                                     -verbose:$false -ErrorAction SilentlyContinue | Select-Object -First 1
            Write-debug "Template: $($template.Name)"
        }

        if ($this.Cluster -ne $null) {
            $cluster = Get-Cluster -Name $this.Cluster `
                                   -verbose:$false -ErrorAction SilentlyContinue | Select-Object -First 1
            Write-debug "Cluster: $($cluster.Name)"
        }

        $datastore = Get-Datastore -Name $this.InitialDatastore `
                                   -verbose:$false -ErrorAction SilentlyContinue | Select-Object -First 1
        write-debug "Datastore: $($datastore.Name)"

        $vm = $null
        # Do we have all the information we need to provision the VM?
        if (($template -ne $null) -and ($datastore -ne $null) -and ($cluster -ne $null)) {

            Write-Verbose "vmname: $($this.VMName)"

            $vm = New-VM -Name $this.VMName `
                         -Template $template `
                         -Datastore $datastore `
                         -ResourcePool $cluster `
                         -DiskStorageFormat Thin `
                         -verbose:$false
        } else {
            Write-Error 'Could not resolve required VMware objects needed to create this VM.'
        }

        if ($vm -ne $null) {
            return $true
        } else {
            return $false
        }
    }

    [bool]SetCPU($vm) {
        [bool]$result = $false

        # If the VM is powered on, we must verify that CPU hotadd
        # is enabled before we can increase the CPU count.
        $task = $null
        if ($vm.PowerState -eq 'PoweredOn') {
            # TODO
            # Deal will powered on VMs and increasing CPU
        } else {
            # It is safe to change the CPU count while powered off
            $spec = New-Object -TypeName Vmware.Vim.VirtualMachineConfigSpec -property @{
                "NumCoresPerSocket" = $this.CoresPerSocket
                "NumCPUs" = $this.TotalvCPU
            }
            $task = $vm.extensiondata.reconfigvm_task($spec)
        }

        # Wait for the task to complete
        $done = $false
        $maxWait = 36 # 3 minutes
        $x = 0
        while (!$done -or ($x -le $maxWait)) {
            $taskResult = get-task -id ('Task-' + $task.value) -verbose:$false
            if ($taskResult.State.toString() -eq 'Success') {
                $done = $true
            } else {
                Start-Sleep -Seconds 5
            }
            $x += 1
        }

        return $result
    }

    #endregion
}
{% endhighlight %}

{% highlight powershell linenos %}
#
# Module manifest for module 'cVMware'
#
# Generated by: Brandon Olin, twitter:@devblackops
#
# Generated on: 3/25/2015
#

@{

# Script module or binary module file associated with this manifest.
RootModule = '.\cVMware.psm1'

# Version number of this module.
ModuleVersion = '1.0.0.0'

# ID used to uniquely identify this module
GUID = '292f17a0-e4f3-461a-906b-674f6f540bbe'

# Author of this module
Author = 'Brandon Olin, twitter:@devblackops'

# Company or vendor of this module
CompanyName = 'http://devblackops.io'

# Copyright statement for this module
Copyright = '(c) 2015 Brandon Olin, twitter:@devblackops. All rights reserved.'

# Description of the functionality provided by this module
Description = 'Class based DSC resource to provision VMs in vCenter'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '5.0'

# Functions to export from this module
FunctionsToExport = '*'

# Cmdlets to export from this module
CmdletsToExport = '*'

# Variables to export from this module
VariablesToExport = '*'

# Aliases to export from this module
AliasesToExport = '*'

# DSC resources to export from this module
DscResourcesToExport = 'cVMware'
}
{% endhighlight %}

### Summary

I hope this gave you a good example of the power of DSC and how it can be used to configure your VMware environment. This project is at the very earliest stages and all ideas are welcome. If you would like to contribute to this project, you can find it on GitHub [here](https://github.com/devblackops/POSHOrigin_vSphere).

Cheers
