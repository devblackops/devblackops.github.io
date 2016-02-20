---
title:  Storing PowerShell Module Default Values in Your User Profile
date:   2015-08-15
featured-image: posts/default.jpg
excerpt: "As you develop your PowerShell modules, you may run into the issue where many of your module cmdlets require a common parameter in order to function. This may be a FQDN for an API endpoint or a folder path your module uses. You could of course, supply this parameter each time you invoke the cmdlet, but this is tedious when working with the module interactively. Below you will see an option for storing PowerShell module default values in your user profile."
comments: true
categories: [PowerShell]
tags: [PowerShell]
---

As you develop your PowerShell modules, you may run into the issue where many of your module cmdlets require a common parameter in order to function. This may be a FQDN for an API endpoint or a folder path your module uses. You could of course, supply this parameter each time you invoke the cmdlet, but this is tedious when working with the module interactively. Below you will see an option for storing PowerShell module default values in your user profile.

### Module Configuration Repository

I like to create a module configuration repository under the user profile directory using a .<modulename> naming convention. Below is an example of my PasswordState module repository under my user profile. In this folder is an options.json file that holds just a couple of common parameters that my PasswordState cmdlets will need.

![](/images/posts/storing-powershell-module-default-values-in-your-profile/passwordstate_repo.png)

### Initializing the Repository

The cmdlet below is part of my PasswordState module that accesses the REST API and retrieves/updates passwords from a secure password vault. This cmdlet will create the module repository if it does not exist and create an options.json with the values provided.

{% highlight powershell linenos %}
function Initialize-PasswordStateRepository {
    <#
        .SYNOPSIS
            Creates PasswordState configuration repository under $env:USERNAME\.passwordstate
        .DESCRIPTION
            Creates PasswordState configuration repository under $env:USERNAME\.passwordstate
            and options.json file to store default values used by other PasswordState cmdlets.
        .PARAMETER ApiEndpoint
            The Uri of your PasswordState site. (i.e. https://passwordstate.local/api)
        .PARAMETER Repository
            Path to credential repository. Default is $env:USERPROFILE\.passwordstate
        .EXAMPLE
            Initialize-PasswordStateRepository -ApiEndpoint 'https://passwordstate.local/api'
        .EXAMPLE
            Initialize-PasswordStateRepository -ApiEndpoint 'https://passwordstate.local/api' -Repository 'C:\PasswordStateCreds'
    #>
    [cmdletbinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ApiEndpoint,

        [string]$Repository = (Join-Path -path $env:USERPROFILE -ChildPath '.passwordstate' -Verbose:$false)
    )

    # If necessary, create our repository under $env:USERNAME\.passwordstate
    $repoPath = (Join-Path -path $env:USERPROFILE -ChildPath '.passwordstate')
    if (-not (Test-Path -Path $repoPath -Verbose:$false)) {
        Write-Debug -Message "Creating PasswordState configuration repository: $repoPath"
        New-Item -ItemType Directory -Path $repoPath -Verbose:$false | Out-Null
    } else {
        Write-Debug -Message "PasswordState configuration repository appears to already be created at [$repoPath]"
    }

    $options = @{
        api_endpoint = $ApiEndpoint
        credential_repository = $Repository
    }

    $json = $options | ConvertTo-Json
    Write-Debug -Message $json
    $json | Out-File -FilePath (Join-Path -Path $repoPath -ChildPath 'options.json') -Force -Confirm:$false -Verbose:$false    
}
{% endhighlight %}

![](/images/posts/storing-powershell-module-default-values-in-your-profile/passwordstate_repo_options.png)

### Referencing Repository Values

Below is a cmdlet internal to the PasswordState module (this cmdlet is not exported to the outside world) that will look inside the **options.json** file for a given option and return the result.

I prefer to name cmdlets / functions that are internal to the module with a **_Verb-Noun** naming scheme. This makes it clear that the cmdlet / function is not meant to be exported.

{% highlight powershell linenos %}
function _GetDefault {
    [cmdletbinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Option
    )

    $repo = (Join-Path -path $env:USERPROFILE -ChildPath '.passwordstate')

    if (Test-Path -Path $repo -Verbose:$false) {

        $options = (Join-Path -Path $repo -ChildPath 'options.json')

        if (Test-Path -Path $options ) {
            $obj = Get-Content -Path $options -Raw | ConvertFrom-Json
            return $obj.$Option
        } else {
            Write-Error -Message "Unable to find [$options]"
        }
    } else {
        Write-Error -Message "Undable to find PasswordState configuration repository at [$repo]"
    }
}
{% endhighlight%}

### Using Default values in cmdlets

Now that we have a place to store our default options and a way to reference those values, other cmdlets in the module can be written to look inside this module repository for default values to parameters. Below is a cmdlet from PasswordState that will list all available API keys that have been securely exported to disk.

{% highlight powershell linenos %}
function Get-PasswordStateApiKey {
    <#
        .SYNOPSIS
            List available PasswordState API keys in the repository.
        .DESCRIPTION
            List available PasswordState API keys in the repository.
        .PARAMETER Repository
            Path to repository. Default is $env:USERPROFILE\.passwordstate
        .EXAMPLE
            Get-PasswordStateApiKey
        .EXAMPLE
            Get-PasswordStateApiKey | Format-Table
        .EXAMPLE
            Get-PasswordStateApiKey -Repository c:\users\joe\data\.customrepo
    #>
    [cmdletbinding()]
    param(
        [string]$Repository = (_GetDefault -Option 'credential_repository')
    )

    if (-not (Test-Path -Path $Repository)) {
        Write-Error 'PasswordState key repository does not exist!'
        break
    }

    $items = Get-ChildItem -Path $Repository -Filter '*.cred'
    return $items
}
{% endhighlight %}

Notice the single parameter to this function:

{% highlight powershell linenos %}
[cmdletbinding()]
param(
    [string]$Repository = (_GetDefault -Option 'credential_repository')
)
{% endhighlight %}

This default value will only be executed if no value is given for **$Repository**. Below you can see how this is used in practice. Notice that the two ways of invoking the cmdlet produce identical results. One is specifying the credential repository explicitly, and the other is relying on the value returned from which will look inside the **options.json** in the module repository and return the default value for **'credential_repository'**.

![](/images/posts/storing-powershell-module-default-values-in-your-profile/get-passwordstateapikey_example.png)

Cheers
