---
title:  POSHOrigin - Part 1 (Summary)
date:   2016-01-03
featured-image: iac.jpg
excerpt: This is the first of a nine part series about POSHOrigin, a PowerShell module that aims to assist you in managing your Infrastructure via custom PowerShell DSC resources.
comments: true
categories: [DevOps]
tags: [DevOps, DSC, PowerShell, VMWare]
---

This is the first of a nine part series about POSHOrigin, a PowerShell module that aims to assist you in managing your Infrastructure via custom PowerShell DSC resources.

<p style="text-align: center;">
  <a target="_blank" class="btn small" href="https://github.com/devblackops/POSHOrigin">POSHOrigin on GitHub→</a>
</p>

### Posts in the series

* Part 1 - Summary
* [Part 2 - Installation]({% post_url 2016-01-03-poshorigin-part-2-installation %})
* [Part 3 - Configuration File]({% post_url 2016-01-03-poshorigin-part-3-configuration-file %})
* [Part 4 - Defaults File]({% post_url 2016-01-03-poshorigin-part-4-defaults-file %})
* [Part 5 - Load, Test, and Execute Configurations]({% post_url 2016-01-03-poshorigin-part-5-load-test-execute-configurations %})
* [Part 6 - Sharing Configurations]({% post_url 2016-01-03-poshorigin-part-6-sharing-configurations %})
* [Part 7 - Credential Resolvers]({% post_url 2016-01-03-poshorigin-part-7-credential-resolvers %})
* [Part 8 - Examples]({% post_url 2016-01-03-poshorigin-part-8-examples %})
* [Part 9 - Wrapping Up]({% post_url 2016-01-03-poshorigin-part-9-wrapping-up %})

### Infrastructure As Code

Infrastructure as Code, or Programmable Infrastructure as some people call it, is meant to describe your infrastructure as an executable configuration in the form of code and is an important concept when thinking about DevOps. Once your infrastructure is described in this way, it can be version controlled, allowing you to see changes over time (this can also serve as a form of backup for your infrastructure).

The configuration files and code that describes your infrastructure has the added benefit as acting as documentation. We all know that traditional documentation in the form of Visio diagrams and Word documents are essentially obsolete the minute that new server or application enters production. Inevitably something in the environment is manually changed and nobody bothers or remembers to update the documentation. With Infrastructure as Code, you make changes to the environment by **CHANGING THE DOCUMENTATION**. Manually making changes to infrastructure is counter to the Infrastructure as Code concept.

POSHOrigin is a framework to manage the desired state of your infrastructure resources via simple and easy to understand configuration files. With POSHOrigin, you can provision infrastructure resources that typical configuration management tools are not designed to manage such as creating virtual machines, load balancer resources, DNS records, etc. POSHOrigin uses PowerShell DSC as the engine to test and remediate your infrastructure via custom DSC modules/resources that do the heavy lifting to bring your infrastructure into the desired state.

### POSHOrigin

POSHOrigin is Infrastructure as Code with PowerShell DSC. It is a PowerShell module that creates and executes DSC configuration documents using custom DSC resources from simple configuration files that represent the resources you with to manage. Using PowerShell DSC for orchestration, POSHOrigin can provision virtual machines, load balancer resources and just about anything you can think of via custom DSC resources.

A typical configuration file to provision a VMware VM could be as simple as the following. Other required options will be pulled in from a defaults file from elsewhere in the configuration repository.

###### my_vms.ps1

{% highlight powershell linenos %}
resource 'POSHOrigin_vSpheree:VM' 'VM01' @{
    defaults = '.\defaults.psd1'
    description = 'Test VM 01'
}
{% endhighlight %}

Running your configuration and thus provisioning your VMs is as simple as running:
{% highlight powershell %}
Get-POSHOriginConfig -Path '.\my_vms.ps1' -Verbose | Invoke-POSHOriginConfig -Verbose
{% endhighlight %}

Or, to be more terse:

{% highlight powershell %}
gpoc . | ipo
{% endhighlight %}

You can also just **test** what would have changed using the normal PowerShell syntax with the **-WhatIf** switch.

{% highlight powershell %}
gpoc . | ipo -verbose -whatif
{% endhighlight %}

### How does it work?

When POSHOrigin processes your configuration files, it converts that desired state into a DSC configuration that is then applied to your local machine, or to a remote provisioner machine. This DSC configuration is a little different than typical DSC configurations designed to manage the state of the machine the configuration is applied to. Instead, this configuration and the custom DSC resources behind it, use the target machine as a proxy for testing the remote infrastructure resources are in the desired state and then using APIs specific to the resource to bring it into the desired state.

### Infrastructure Resources you can manage with POSHOrigin

Here are a few use cases for POSHOrigin. Any infrastructure resource that have an API available could be exposed as a custom POSHOrigin DSC resource. Using this framework, you can model your entire infrastructure as code.

Make sure that the virtual machine **VM01** exists on vSphere server **vsphere01.mydomain.com** and has **2** vCPU and **4GB** of vRAM.
Make sure that the Citrix NetScaler **netscaler01.mydomain.com** has a VIP setup with IP address **192.168.100.200** and that it is using **roundrobin** as it's load balancing method.

Cheers,

Brandon
