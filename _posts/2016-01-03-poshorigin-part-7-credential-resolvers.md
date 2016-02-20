---
title:  POSHOrigin - Part 7 (Credential Resolvers)
date:   2016-01-03
featured-image: iac.jpg
excerpt: This is part 7 of a 9 part series about POSHOrigin, a PowerShell module that aims to assist you in managing your Infrastructure via custom PowerShell DSC resources.
comments: true
categories: [DevOps]
tags: [DevOps, DSC, PowerShell, VMWare]
---

This is part 7 of a 9 part series about POSHOrigin, a PowerShell module that aims to assist you in managing your Infrastructure via custom PowerShell DSC resources.

<p style="text-align: center;">
  <a target="_blank" class="btn small" href="https://github.com/devblackops/POSHOrigin">POSHOrigin on GitHub→</a>
</p>

### Posts in the series

* [Part 1 - Summary]({% post_url 2016-01-03-poshorigin-part-1-summary %})
* [Part 2 - Installation]({% post_url 2016-01-03-poshorigin-part-2-installation %})
* [Part 3 - Configuration File]({% post_url 2016-01-03-poshorigin-part-3-configuration-file %})
* [Part 4 - Defaults File]({% post_url 2016-01-03-poshorigin-part-4-defaults-file %})
* [Part 5 - Load, Test, and Execute Configurations]({% post_url 2016-01-03-poshorigin-part-5-load-test-execute-configurations %})
* [Part 6 - Sharing Configurations]({% post_url 2016-01-03-poshorigin-part-6-sharing-configurations %})
* Part 7 - Credential Resolvers
* [Part 8 - Examples]({% post_url 2016-01-03-poshorigin-part-8-examples %})
* [Part 9 - Wrapping Up]({% post_url 2016-01-03-poshorigin-part-9-wrapping-up %})

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
