---
title:  POSHOrigin - Examples
date:   2016-01-03
featured-image: iac.jpg
series:
  name: "POSHOrigin"
  excerpt: POSHOrigin, a PowerShell module that aims to assist you in managing your Infrastructure via custom PowerShell DSC resources.
excerpt: This is part 8 of a nine part series about POSHOrigin, a PowerShell module that aims to assist you in managing your Infrastructure via custom PowerShell DSC resources.
comments: true
categories: [DevOps]
tags: [DevOps, DSC, PowerShell, VMWare]
---

{% include series.html %}

<p style="text-align: center;">
  <a target="_blank" class="btn small" href="https://github.com/devblackops/POSHOrigin">POSHOrigin on GitHub→</a>
</p>

### Examples

Creating a VMware VM using the [POSHOrigin_vSphere](https://github.com/devblackops/POSHOrigin_vSphere) DSC module

This will create a VMware VM called **serverxyz**, join it to an Active Directory domain, install the Chef client on it, then assign and execute a Chef run list.

##### my_vm.ps1

{% highlight powershell linenos %}
resource 'POSHOrigin_vSphere:vm' 'serverxyz' @{
    ensure = 'present'
    description = 'Test VM'
    vCenter = 'vcenter01.mydomain.com'
    datacenter = 'datacenter01'
    cluster = 'cluster01'
    vmTemplate = 'W2K12_R2_Std'
    customizationSpec = 'W2K12_R2'
    powerOnAfterCreation = $true
    totalvCPU = 2
    coresPerSocket = 1
    vRAM = 4
    initialDatastore = 'datastore01'
    networks = @{
        portGroup = 'VLAN_500'
        ipAssignment = 'Static'
        ipAddress = '192.168.195.254'
        subnetMask = '255.255.255.0'
        defaultGateway = '192.168.195.1'
        dnsServers = @('192.168.50.50','192.168.50.60')
    }
    disks = @(
        @{
            name = 'Hard disk 1'
            sizeGB = 50
            type = 'flat'
            format = 'Thick'
            volumeName = 'C'
            volumeLabel = 'NOS'
            blockSize = 4096
        }
    )
    vCenterCredentials = Get-POSHOriginSecret 'pscredential' @{
        username = 'administrator@vsphere.local'
        password = '<your password here>'
    }
    guestCredentials = Get-POSHOriginSecret 'pscredential' @{
        username = 'administrator'
        password = '<your password here>'
    }
    domainJoinCredentials = Get-POSHOriginSecret 'pscredential' @{
        username = 'administrator'
        password = '<your password here>'
    }
    provisioners = @(
        @{
            name = 'DomainJoin'
            options = @{
               domain = 'mydomain.com'
               oupath = 'ou=servers, dc=mydomain, dc=com'
           }
        }
        @{
            name = 'Chef'
            options = @{
                nodeName = 'serverxyz.mydomain.com'
                url = 'https://chefsvr.mydomain.com/organizations/myorg'
                source = '<URL to Chef MSI file>'
                validatorKey = '<URL to organization validator .pem file>'
                cert = '<URL to issuing CA .crt file>'
                runList = @(
                    @{ role = 'base::setup_base' }
                    @{ recipe = 'myapp::default' }
                )
                environment = 'dev'
                attributes = @{
                    'myapp.prop1' = 42
                    'myapp.prop2' = 'something'
                }
            }
        }
    )
}
{% endhighlight %}

### Creating a NetScaler VIP using the [POSHOrigin_NetScaler](https://github.com/devblackops/POSHOrigin_NetScaler) DSC module

This will create a Citrix NetScaler load balancer server instance pointing to the IP of the VM we just created (**192.168.195.254**), as well as a VIP with an IP of **192.168.100.100**.

##### my_ns_resources.ps1

{% highlight powershell linenos %}
resource 'POSHOrigin_NetScaler:LBServer' 'serverxyz' @{
    Ensure = 'Present'
    NetScalerFQDN = 'mynetscaler.mydomain.com'
    IPAddress = '192.168.195.254'
    Comments = 'This is a comment'
    TrafficDomainId = 1
    State = 'ENABLED'
    Credential = Get-POSHOriginSecret 'pscredential' @{
        username = 'administrator'
        password = '<your password here>'
    }
}

resource 'POSHOrigin_NetScaler:LBVirtualServer' 'lbserverxyz' @{
    Ensure = 'Present'
    NetScalerFQDN = 'mynetscaler.mydomain.com'
    Comments = 'This is a comment'
    IPAddress = '192.168.100.100'
    Port = 80
    ServiceType = 'HTTP'
    LBMethod = 'ROUNDROBIN'    
    State = 'ENABLED'
    Credential = Get-POSHOriginSecret 'pscredential' @{
        username = 'administrator'
        password = 'K33p1t53cr3tK33p1t5@f3'
    }
}
{% endhighlight %}

### Creating a DNS A record using the [POSHOrigin_ActiveDirectoryDNS](https://github.com/devblackops/POSHOrigin_ActiveDirectoryDNS) DSC module

This will create an **A** record in DNS called **web01.mydomain.local** that points to the IP of the VM we just created (**10.45.195.254**).

##### my_dns_record.ps1

{% highlight powershell linenos %}
resource 'ActiveDirectoryDNS:ARecord' 'web01' @{
    ZoneName = 'mydomain.local'
    IpAddress = '10.45.195.254'
    DnsServer = 'dc01.mydomain.com'
    CreatePtr = $true
    Credential = Get-POSHOriginSecret 'pscredential' @{
        username = 'mydomain\administrator'
        password = 'K33p1t53cr3tK33p1t5@f3'
    }
}
{% endhighlight %}

### Using all three resources in the same file

Here is an example of combined all resources into a single file as well as extracting some of the configurations into defaults files.

##### my_app_env.ps1

{% highlight powershell linenos %}
resource 'POSHOrigin_vSphere:VM' 'serverxyz' @{
    defaults = '.\my_vm_defaults.psd1'
    totalvCPU = 2
    coresPerSocket = 1
    vRAM = 4
    networks = @{
        portGroup = 'VLAN_500'
        ipAssignment = 'Static'
        ipAddress = '192.168.100.100'
        subnetMask = '255.255.255.0'
        defaultGateway = '192.168.100.1'
        dnsServers = @('192.168.50.50','192.168.50.60')
    }
    vCenterCredentials = Get-POSHOriginSecret 'pscredential' @{
        username = 'administrator@vsphere.local'
        password = '<your password here>'
    }
    guestCredentials = Get-POSHOriginSecret 'pscredential' @{
        username = 'administrator'
        password = '<your password here>'
    }
    domainJoinCredentials = Get-POSHOriginSecret 'pscredential' @{
        username = 'administrator'
        password = '<your password here>'
    }
    provisioners = @(
        @{
            name = 'DomainJoin'
            options = @{
               domain = 'mydomain.com'
               oupath = 'ou=servers, dc=mydomain, dc=com'
           }
        }
        @{
            name = 'Chef'
            options = @{
                nodeName = 'vm01.mydomain.com'
                url = 'https://chefsvr.mydomain.com/organizations/myorg'
                source = '<URL to Chef MSI file>'
                validatorKey = '<URL to organization validator .pem file>'
                cert = '<URL to issuing CA .crt file>'
                runList = @(
                    @{ role = 'base::setup_base' }
                    @{ recipe = 'myapp::default' }
                )
                environment = 'prod'
                attributes = @{
                    'myapp.prop1' = 42
                    'myapp.prop2' = 'something'
                }
            }
        }
    )
}

resource 'POSHOrigin_NetScaler:LBServer' 'serverxyz' @{
    defaults = '.\my_ns_defaults.psd1'
    ipAddress = '192.168.100.100'
    comments = 'This is a comment'
    trafficDomainId = 1
    state = 'ENABLED'
    credential = Get-POSHOriginSecret 'pscredential' @{
        username = 'administrator'
        password = 'K33p1t53cr3tK33p1t5@f3'
    }
}

resource 'POSHOrigin_NetScaler:LBVirtualServer' 'lbserverxyz' @{
    defaults = '.\my_ns_defaults.psd1'
    comments = 'This is a comment'
    ipAddress = '192.168.100.101'
    port = 80
    serviceType = 'HTTP'
    lbMethod = 'ROUNDROBIN'    
    state = 'ENABLED'
    credential = Get-POSHOriginSecret 'pscredential' @{
        username = 'administrator'
        password = 'K33p1t53cr3tK33p1t5@f3'
    }
}

resource 'POSHOrigin_ActiveDirectoryDNS:ARecord' 'web01' @{
    defaults = '.\my_vm_defaults.psd1'
    ipAddress = '10.45.195.254'
    credential = Get-POSHOriginSecret 'pscredential' @{
        username = 'mydomain\administrator'
        password = 'K33p1t53cr3tK33p1t5@f3'
    }
}
{% endhighlight %}

Cheers
