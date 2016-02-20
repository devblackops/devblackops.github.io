---
title:  POSHOrigin - Part 6 (Sharing Configurations)
date:   2016-01-03
featured-image: iac.jpg
excerpt: This is part 6 of a 9 part series about POSHOrigin, a PowerShell module that aims to assist you in managing your Infrastructure via custom PowerShell DSC resources.
comments: true
categories: [DevOps]
tags: [DevOps, DSC, PowerShell, VMWare]
---

This is part 6 of a 9 part series about POSHOrigin, a PowerShell module that aims to assist you in managing your Infrastructure via custom PowerShell DSC resources.

<p style="text-align: center;">
  <a target="_blank" class="btn small" href="https://github.com/devblackops/POSHOrigin">POSHOrigin on GitHub→</a>
</p>

### Posts in the series

* [Part 1 - Summary]({% post_url 2016-01-03-poshorigin-part-1-summary %})
* [Part 2 - Installation]({% post_url 2016-01-03-poshorigin-part-2-installation %})
* [Part 3 - Configuration File]({% post_url 2016-01-03-poshorigin-part-3-configuration-file %})
* [Part 4 - Defaults File]({% post_url 2016-01-03-poshorigin-part-4-defaults-file %})
* [Part 5 - Load, Test, and Execute Configurations]({% post_url 2016-01-03-poshorigin-part-5-load-test-execute-configurations %})
* Part 6 - Sharing Configurations
* [Part 7 - Credential Resolvers]({% post_url 2016-01-03-poshorigin-part-7-credential-resolvers %})
* [Part 8 - Examples]({% post_url 2016-01-03-poshorigin-part-8-examples %})
* [Part 9 - Wrapping Up]({% post_url 2016-01-03-poshorigin-part-9-wrapping-up %})

### Sharing Configurations

Some resource definitions inside your configuration file may have a large number of options associated with them and you may find yourself repeating common configuration options across your resources. For this reason, configuration snippets can be created that will be loaded into your resource configuration when [Get-POSHOriginConfig](https://github.com/devblackops/POSHOrigin/wiki/Get-POSHOriginConfig) is executed. These options are stored inside a file with the **.psd1** extension. This is best used when the option for the resource is expecting a hashtable or an array. You could use this with simple strings or integers but it will be less useful. You reference the **name** of this configuration snippet (minus the .psd1 extension) using the [Get-POSHDefault](https://github.com/devblackops/POSHOrigin/wiki/Get-POSHDefault) function

##### standard_disks.psd1

{% highlight powershell linenos %}
@(
    @{
        name = 'Hard disk 1'
        sizeGB = 50
        type = 'flat'
        format = 'Thick'
        volumeName = 'C'
        volumeLabel = 'NOS'
        blockSize = 4096
    },
    @{
       name = 'Hard disk 2'
       sizeGB = 100
       type = 'flat'
       format = 'Thick'
       volumeName = 'D'
       volumeLabel = 'Data'
       blockSize = 4096
    }
)
{% endhighlight %}

##### my_vm_config.ps1

{% highlight powershell linenos %}
resource 'vsphere:vm' 'VM01' @{
    ensure = 'present'
    description = 'Test VM'
    ###
    # Other options omitted for brevity
    ###
    disks = Get-POSHDefault 'standard_disks'
}
{% endhighlight %}
