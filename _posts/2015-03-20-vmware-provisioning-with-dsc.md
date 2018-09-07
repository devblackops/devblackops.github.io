---
title:  Idea for VMware Provisioning with DSC
date:   2015-03-20
featured-image: posts/idea-for-vmware-provisioning-with-dsc/vmware_plus_powershell.png
excerpt: "Here is an idea for VM Provisioning with DSC. This is how a custom DSC resource might look like in order to deploy a VM into a given vCenter. This DSC configuration would not target the VM itself but rather the vCenter server or maybe a proxy server with PowerCLI installed."
comments: true
hide_from_feed: true
categories: [DevOps, DSC, PowerShell, VMware]
tags: [DSC, PowerShell, VMware]
---

>UPDATE - I've started a series of posts about POSHOrigin. A PowerShell module and DSC resource that takes this to the next level. Check it out [here](http://devblackops.io/poshorigin-part-1-summary/){:target="_blank"}.

Here is an idea for VM Provisioning with DSC. This is how a custom DSC resource might look like in order to deploy a VM into a given vCenter. This DSC configuration would not target the VM itself but rather the vCenter server or maybe a proxy server with PowerCLI installed. More to come on this as I actually start writing the module. Stay tuned.

{% highlight powershell linenos %}
Configuration WebServerVMDeploy {
    param ()

    Import-DscResource -ModuleName cVMware

    Node "localhost" {
        cVM deployVM {
            Ensure = "Present"
            Name = "webServer01"
            vCenter = "vcenter01.local"
            Datacenter = "Prod Datacenter"
            Cluster = "ProdCluster01"
            Template = "windows2012R2StdTemplate"
            vCPU = @{
                "Sockets" = "1";
                "Cores" = "2";
            }
            vRAM = 4
            Disks = @(
                @{
                    "SizeGB" = "40"
                    "Datastore" = "Datastore01"
                    "Format" = "Thin"
                },
                @{
                    "SizeGB" = "20"
                    "Datastore" = "Datastore02"
                    "Format" = "ThickLazyZero"
                }
            )
            NICs = @(
                @{
                    "IP" = "192.168.100.100"
                    "NetMask" = "255.255.255.0"
                    "Gateway" = "192.168.100.1"
                    "PortGroup" = "WebPortGroup01"
                }
            )
        }
    }
}

$MOFpath = 'C:\Scripts\DSC\VMWareTest'
WebServerVMDeploy -OutputPath $MOFpath
Start-DscConfiguration -ComputerName 'localhost' -Wait -Force -Verbose -Path $MOFpath
{% endhighlight %}
