---
title:  POSHOrigin - Part 4 (Defaults File)
date:   2016-01-03
featured-image: iac.jpg
excerpt: This is part 4 of a 9 part series about POSHOrigin, a PowerShell module that aims to assist you in managing your Infrastructure via custom PowerShell DSC resources.
comments: true
categories: [DevOps]
tags: [DevOps, DSC, PowerShell, VMWare]
---

This is part 4 of a 9 part series about POSHOrigin, a PowerShell module that aims to assist you in managing your Infrastructure via custom PowerShell DSC resources.

<p style="text-align: center;">
  <a target="_blank" class="btn small" href="https://github.com/devblackops/POSHOrigin">POSHOrigin on GitHub→</a>
</p>

### Posts in the series

* [Part 1 - Summary]({% post_url 2016-01-03-poshorigin-part-1-summary %})
* [Part 2 - Installation]({% post_url 2016-01-03-poshorigin-part-2-installation %})
* [Part 3 - Configuration File]({% post_url 2016-01-03-poshorigin-part-3-configuration-file %})
* Part 4 - Defaults File
* [Part 5 - Load, Test, and Execute Configurations]({% post_url 2016-01-03-poshorigin-part-5-load-test-execute-configurations %})
* [Part 6 - Sharing Configurations]({% post_url 2016-01-03-poshorigin-part-6-sharing-configurations %})
* [Part 7 - Credential Resolvers]({% post_url 2016-01-03-poshorigin-part-7-credential-resolvers %})
* [Part 8 - Examples]({% post_url 2016-01-03-poshorigin-part-8-examples %})
* [Part 9 - Wrapping Up]({% post_url 2016-01-03-poshorigin-part-9-wrapping-up %})

### Defaults File

The defaults file is where you can store common resource configuration data that will be shared across multiple configurations. When each **resource** block in your configuration is processed, if it specifies a defaults file, those defaults will be converted into a hashtable that will get merged with the hashtable of the resource. If there are any duplicates between the defaults file and the resource block, the values from the **resource** block will be used.

##### file_defaults.psd1

{% highlight powershell linenos %}
@{
    ensure = 'present'
    path = 'c:\'
    contents = 'this is some content'
}
{% endhighlight %}

##### files.ps1

{% highlight powershell linenos %}
resource 'example:poshfile' 'file1.txt' @{
    defaults = '.\file_defaults.psd1'
}
{% endhighlight %}

The examples above are the equivalent of specifying all options in the configuration file.

##### create_file.ps1

{% highlight powershell linenos %}
resource 'example:poshfile' 'file1.txt' @{
    ensure = 'present'
    path = 'c:\'
    contents = 'this is some content'
}
{% endhighlight %}

Cheers
