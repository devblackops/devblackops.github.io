---
title:  POSHOrigin - Load, Test, and Execute Configurations
date:   2016-01-03
featured-image: iac.jpg
series:
  name: "POSHOrigin"
  excerpt: POSHOrigin, a PowerShell module that aims to assist you in managing your Infrastructure via custom PowerShell DSC resources.
excerpt: This is part 5 of a 9 part series about POSHOrigin, a PowerShell module that aims to assist you in managing your Infrastructure via custom PowerShell DSC resources.
comments: true
categories: [DevOps]
tags: [DevOps, DSC, PowerShell, VMWare]
---

{% include series.html %}

<p style="text-align: center;">
  <a target="_blank" class="btn small" href="https://github.com/devblackops/POSHOrigin">POSHOrigin on GitHub→</a>
</p>

### Loading Configurations

You load POSHOrigin configurations by calling the [Get-POSHOriginConfig](https://github.com/devblackops/POSHOrigin/wiki/Get-POSHOriginConfig) function and specifying the file, files, or folder to process. You can recursively process subfolders as well. Get-POSHOriginConfig returns one or more custom objects that can then be converted into DSC configurations.

{% highlight powershell %}
$myConfig = Get-POSHOriginConfig -Path '.\myFolder.ps1' -Verbose
{% endhighlight %}

{% highlight powershell %}
$myConfigs = '.\myfile1.ps1', 'myfile2.ps1' | Get-POSHOriginConfig -Verbose
{% endhighlight %}

{% highlight powershell %}
$myConfigs = Get-POSHOriginConfig -Path . -Recurse -Verbose
{% endhighlight %}

### Testing Configurations

You can test your infrastructure for compliance against your configuration by calling the [Invoke-POSHOrigin](https://github.com/devblackops/POSHOrigin/wiki/Invoke-POSHOrigin) function with the **-WhatIf** switch. Internally, POSHOrigin will execute the **Test-DscConfiguration** DSC cmdlet against the MOF file that is compiled.

>**NO RESOURCES WILL BE CREATED, DELETED, OR MODIFIED** when using the **-WhatIf** switch.

{% highlight powershell linenos %}
$myConfig = Get-POSHOriginConfig -Path '.\vm_config.ps1' -Verbose
Invoke-POSHOrigin -ConfigData $myConfig -Verbose -WhatIf
Get-POSHOriginConfig -Path '.\vm_config.ps1' -Verbose | Invoke-POSHOrigin -Verbose -WhatIf
{% endhighlight %}

### Executing Configurations

You can execute your POSHOrigin configuration by calling the [Invoke-POSHOrigin](https://github.com/devblackops/POSHOrigin/wiki/Invoke-POSHOrigin) function. Internally, POSHOrigin will execute the **Start-DscConfiguration** DSC cmdlet against the MOF file that is compiled.

>**RESOURCES WILL BE CREATED, DELETED, OR MODIFIED**. You should run Invoke-POSHOrigin with the **-WhatIf** prior to this in order to get an idea of changes will occur.

{% highlight powershell linenos %}
$myConfig = Get-POSHOriginConfig -Path '.\vm_config.ps1' -Verbose
Invoke-POSHOrigin -ConfigData $myConfig -Verbose
{% endhighlight %}

Cheers
