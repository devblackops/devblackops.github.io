---
title:  "Import / Export PowerShell Credentials Module"
date:   2015-03-18
featured-image: powershell-logo.png
comments: true
hide_from_feed: true
categories: [PowerShell]
tags: [Credentials, PowerShell]
---

Here is a handle little PS module I picked up from [halr9000.com](halr9000.com) to import/export credentials to a file securely. The only person who can import and therefore decrypt the file is the user who exported it.

Usage example:

{% highlight powershell linenos %}
Import-Module Credentials
$creds = Get-Credential

Export-PSCredential -Credential $creds -Path 'c:\temp\creds.xml'
$newCreds = Import-PScredential -Path 'C:\Temp\creds.xml'
{% endhighlight %}
