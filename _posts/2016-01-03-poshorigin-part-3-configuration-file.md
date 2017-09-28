---
title:  POSHOrigin - Configuration File
date:   2016-01-03
featured-image: iac.jpg
series:
  name: "POSHOrigin"
  excerpt: POSHOrigin, a PowerShell module that aims to assist you in managing your Infrastructure via custom PowerShell DSC resources.
excerpt: This is part 3 of a 9 part series about POSHOrigin, a PowerShell module that aims to assist you in managing your Infrastructure via custom PowerShell DSC resources.
comments: true
categories: [DevOps]
tags: [DevOps, DSC, PowerShell, VMWare]
---

{% include series.html %}

<p style="text-align: center;">
  <a target="_blank" class="btn small" href="https://github.com/devblackops/POSHOrigin">POSHOrigin on GitHub→</a>
</p>

### Configuration File

The POSHOrigin configuration file is where you define your resources to be evaluated by POSHOrigin. These configuration files will be read and translated into DSC configurations that get applied either to your local machine, or to a provisioning machine in order to provision infrastructure.

You define your resources in the configuration file by adding a **resource** block for each resource you want to provision.

##### my_folder.ps1
{% highlight powershell linenos %}
resource 'example:poshfolder' 'folder01' @{
    description = 'this is an example folder'
    ensure = 'present'
    path = 'c:\'
}
{% endhighlight %}

Defining multiple resources in the same file is supported as well.

##### create_folders.ps1

{% highlight powershell linenos %}
resource 'example:poshfolder' 'folder01' @{
    description = 'this is an example folder'
    ensure = 'present'
    path = 'c:\'
}

resource 'example:poshfolder' 'folder02' @{
    description = 'this is another example folder'
    ensure = 'present'
    path = 'c:\'
}
{% endhighlight %}


The **resource** function is really an alias for the function New-POSHOriginResource that has **three** required parameters:

The resource function will evaluate the parameters given to it, merge default options if specified, resolve any secrets listed into PowerShell credentials, and return one or more PowerShell custom objects. When you run **Get-POSHOriginConfig** (or **gpoc**) against a configuration file or folder, the resultant collection of PowerShell custom objects will be returned back to you. This array of objects can then be converted into a DSC configuration by passing them to **Invoke-POSHOrigin** or (**ipo**).

{% highlight powershell linenos %}
$myConfigs = Get-POSHOriginConfig -Path .\myFolder.ps1 -Verbose
$myConfigs | Invoke-POSHOrigin -Verbose
{% endhighlight %}

Cheers
