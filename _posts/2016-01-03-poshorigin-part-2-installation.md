---
title:  POSHOrigin - Installation
date:   2016-01-03
featured-image: iac.jpg
series:
  name: "POSHOrigin"
  excerpt: POSHOrigin, a PowerShell module that aims to assist you in managing your Infrastructure via custom PowerShell DSC resources.
excerpt: This is part 2 of a nine part series about POSHOrigin, a PowerShell module that aims to assist you in managing your Infrastructure via custom PowerShell DSC resources.
comments: true
categories: [DevOps]
tags: [DevOps, DSC, PowerShell, VMWare]
---

{% include series.html %}

<p style="text-align: center;">
  <a target="_blank" class="btn small" href="https://github.com/devblackops/POSHOrigin">POSHOrigin on GitHub→</a>
</p>

### Setup / Initialization

Download Windows Management Framework 5 Production Preview

POSHOrigin uses class based DSC resources therefore PowerShell 5 is required. This is only required on the machine that is executing the configuration.

If you have Chocolatey already installed on your machine, just run the following to install WMF 5.

{% highlight powershell %}
choco install powershell -pre
{% endhighlight %}

To install Chocoletey, run the following:

{% highlight powershell %}
iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
{% endhighlight %}

If you want to install WMF 5 manually, use this [link](https://www.microsoft.com/en-us/download/details.aspx?id=48729){:target="_blank"}.

### Download POSHOrigin

Run the following commands to download the module from GitHub and extract it to your modules folder. Make sure you run PowerShell as **Administrator** so it can extract the module to **${env:ProgramFiles}\WindowsPowershell\Modules**.

{% highlight powershell linenos %}
Invoke-WebRequest -Uri 'https://github.com/devblackops/POSHOrigin/archive/master.zip' -OutFile "$env:UserProfile\Downloads\POSHOrigin-master.zip"
UnBlock-File -Path "$env:UserProfile\Downloads\POSHOrigin-master.zip"
Expand-Archive -Path "$env:UserProfile\Downloads\POSHOrigin-master.zip" -DestinationPath "$env:ProgramFiles\WindowsPowershell\Modules" -Force
Move-Item -Path "$env:ProgramFiles\WindowsPowershell\Modules\POSHOrigin-master" -Destination "$env:ProgramFiles\WindowsPowershell\Modules\POSHOrigin"
{% endhighlight %}

### Verify the module

Verify that the module is correctly installed by running the following:

{% highlight powershell %}
Get-Module -Name POSHOrigin -ListAvailable
{% endhighlight %}

### Initialize POSHOrigin

{% highlight powershell %}
Initialize-POSHOrigin -Verbose
{% endhighlight %}

Initializing POSHOrigin will do the following:

1. Initializes the POSHOrigin configuration repository that will hold default values for cmdlet parameters. By default this will be **$env:UserProfile\.poshorigin**.
2. Configures the DSC Local Configuration Manager on the local host for **PUSH** mode.
3. Enables PS remoting.
4. Sets WSMan TrustedHosts to '*' in order to allow PowerShell remoting to a machine by IP address.

Cheers
