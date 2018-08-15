---
title:  VMware Template Creation and Managment with Packer
date:   2016-03-29
draft: true
featured-image: packer.png
excerpt: 'asdfasdfasdf'
comments: true
categories: [DevOps]
tags: [DevOps, PowerShell, VMWare, Packer]
---

For most VMware administrators, managing VM templates is a manual and tedious task that is probably given to
the new person on the team as a cruel form of initiation. ```It doesn't have to be this way```. This post will cover
how you can utilize a few awesome technologies to produce fully automated VMware templates and deploy those
templates into your envionrment.

* TOC
{:toc}

### Tools
* [Chocolatey](https://chocolatey.org/) - Package management for Windows.
* [Packer](https://packer.io) - Automates the creation of machine images.
* [VMWare Workstation](https://www.vmware.com/products/workstation) - Desktop virtualzation.
* [psake](https://github.com/psake/psake) - A build automation tool. Use it. Love it.
* [BoxStarter](http://boxstarter.org/) - Repeatable, reboot resilient Windows environment installations using [Chocolatey](https://chocolatey.org/) packages.
* [PowerCLI](https://www.vmware.com/support/developer/PowerCLI/) - PowerShell module for managment VMware vSphere.
* [Artifactory](https://www.jfrog.com/artifactory/) - Artifact repository manager.
* [ovftool](https://www.vmware.com/support/developer/ovf/) - Command-line utility for importing and exporting OVF packages.
* [curl](https://curl.haxx.se/download.html) - Command-line utility for transfering data.

### Build server
First off your going to want to provision a build server that this process will run on. For this post, I'm going to use a vanilla
but fully patched Windows 2012 R2 VM. You're going to want to assign enough resources (vCPU and RAM) to this VM in order to run
VMware Workstation. You'll also want to assign a decent amount of storage to handle the VMWare Workstation VM and associated artifacts
as part of the build process.

> Yes, we're going to be using nested virtualization (having a VM run another VM to produce another VM). That's very meta isn't it :)

#### Build server resources
- VM: Windows 2012 R2 Standard
- vCPU: 2
- vRAM: 6GB
- Storage: C:\ 100 GB
           D:\ 50 GB

>We're going to need a fairly big ```C``` drive as Packer will copy the ```.vmdk``` produced during it's build phase to ```$env:temp```
during it's post-processor phase. These temporary files will be automatically cleaned up by Packer.

[Github issue regarding Packer temp directory usage](https://github.com/mitchellh/packer/issues/1618)

### Build Server Software
Install the following software on the build server with Chocolatey. Feel free to use other installation methods if you like.

#### Chocolatey, Packer, psake, and curl
{% highlight powershell %}
if(!($env:ChocolateyInstall) -or !(Test-Path "$env:ChocolateyInstall")){
    iex ((new-object net.webclient).DownloadString("http://bit.ly/psChocInstall"))
}
if(!(Get-Command git -ErrorAction SilentlyContinue)) { cinst git -y }}
if(!(Get-Command packer -ErrorAction SilentlyContinue)) { cinst packer -y }
if(!(Test-Path $env:ChocolateyInstall\lib\Psake*)) { cinst psake -y }
if(!(Test-Path -Path 'C:\ProgramData\chocolatey\lib\curl\tools\curl.exe')) { cinst curl -y }
{% endhighlight %}

#### VMWare Workstation

Grab a copy of VMWare workstation and run the following command to install.

{% highlight powershell %}
.\VMware-workstation-full-12.1.0-3272444.exe /s /v /qn EULAS_AGREED=1 SERIALNUMBER='<YOUR SERIAL NUMEBR' AUTOSOFTWAREUPDATE=0
{% endhighlight %}

#### PowerCLI
Download the latest version of PowerCLI and run the following command to install. You can start
[here](https://my.vmware.com/group/vmware/get-download?downloadGroup=PCLI630R1).

{% highlight powershell %}
.\VMware-PowerCLI-6.3.0-3639347.exe /b"C:\Windows\Temp" /VADDLOCAL=ALL /S /V"/qn ALLUSERS=1 REBOOT=ReallySuppress"
{% endhighlight %}

#### ovftool

Download ovftool from [https://www.vmware.com/support/developer/ovf]()








