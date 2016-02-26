---
title:  POSHOrigin - Credential Resolvers
date:   2016-01-03
featured-image: iac.jpg
series:
  name: "POSHOrigin"
  excerpt: POSHOrigin, a PowerShell module that aims to assist you in managing your Infrastructure via custom PowerShell DSC resources.
excerpt: This is part 7 of a 9 part series about POSHOrigin, a PowerShell module that aims to assist you in managing your Infrastructure via custom PowerShell DSC resources.
comments: true
categories: [DevOps]
tags: [DevOps, DSC, PowerShell, VMWare]
---

{% include series.html %}

<p style="text-align: center;">
  <a target="_blank" class="btn small" href="https://github.com/devblackops/POSHOrigin">POSHOrigin on GitHub→</a>
</p>

### Credential Resolvers

Credential resolvers are various methods POSHOrigin can use to create a PowerShell credential object from data in the configuration file. These credentials are then passed to the DSC resource when it is compiled. Using resolvers, sensitive data like usernames / passwords can be stored separately from the configuration and pulled in when the configuration file is read and executed.

Currently, POSHOrigin supports the following resolvers:

* **PasswordState** - Resolves a credential object using [ClickStudio's](http://www.clickstudios.com.au/) PasswordState vault. This resolver needs my [PasswordState](https://github.com/devblackops/PasswordState) module to be installed in order to function.
* **ProtectedData** - Resolves a credential object using Dave Wyatt's [ProtectedData](https://github.com/dlwyatt/ProtectedData) PowerShell module.
* **PSCredential** - Resolves a credential object using a plain text username and password. **USE ONLY FOR TESTING!**

### PasswordState Example

{% highlight powershell linenos %}
resource 'vsphere:vm' 'VM01' @{
    ensure = 'present'
    description = 'Test VM'
    ###
    # Other options omitted for brevity
    ###          
    vcenterCredentials = Get-POSHOriginSecret 'passwordstate' @{
        endpoint = 'https://passwordstate.local/api'
        credApiKey = '<your API key>'
        passwordId = 1234
    }
}
{% endhighlight %}

### PSCredential Example

{% highlight powershell linenos %}
resource 'vsphere:vm' 'VM01' @{
    ensure = 'present'
    description = 'Test VM'
    ###
    # Other options omitted for brevity
    ###          
    vcenterCredentials = Get-POSHOriginSecret 'pscredential' @{
        username = 'svcvcenter'
        password = 'password123!'
    }
}
{% endhighlight %}
