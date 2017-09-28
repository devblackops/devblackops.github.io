---
title:  PowerShell Module for ClickStudio’s PasswordState
date:   2015-08-21
featured-image: posts/password_1.jpg
excerpt: "Most organizations will have some sort of enterprise or departmental password vault. If they don't, they seriously need to think about implementing one. Below you'll see a PowerShell module I've written to interface with ClickStudio's PasswordState application via their REST API."
comments: true
categories: [DevOps]
tags: [Credentials, DevOps, PowerShell]
---

Most organizations will have some sort of enterprise or departmental password vault. If they don't, they seriously need to think about implementing one. Below you'll see a PowerShell module I've written to interface with ClickStudio's PasswordState application via their REST API.

<p style="text-align: center;">
  <a target="_blank" class="btn small" href="https://github.com/devblackops/PasswordState">PasswordState on GitHub→</a>
</p>

I've used PasswordState for a number of years now and I find it to be a pretty decent password manager for both small organizations and large enterprises. It has a ton of features to support different scenarios, is free for 5 users or less, and is very reasonably priced for additional or unlimited users.

### Brief PasswordState Overview

Taken from ClickStudio's site:

>PasswordState is an on-premise web based solution for Enterprise Password Management, where teams of people can access and share sensitive password resources.

If you want to know more about it, check out their [site](http://www.clickstudios.com.au/).

### PowerShell Module

PasswordState's API documentation is very straightforward and gives examples using **curl** for all of their commands. I've taken most of their examples and created PowerShell cmdlets for them. Here is what I have created:

* **Get-PasswordStateAPIKey** - Lists exported API keys for use in PasswordState.
* **Get-PasswordStatePassword** - Get password by ID.
* **Get-PasswordStatePasswordHistory** - Get the change history for a password.
* **Get-PasswordStateList** - Get all password lists.
* **Get-PasswordStateListPasswords** - Get all passwords in a given password list.
* **Get-PasswordStateAllPasswords** - Get all passwords from PasswordState.
* **Export-PasswordsStateAPIKey** - Securely export an API key (in the form of a PS credential) to the file system. Only the user who exported the API key can decrypt it.
* **Import-PasswordStateAPIKey** - Import a previously exported API key into a PS credential object.
* **Find-PasswordStatePassword** - Search PasswordState based on various fields and return any matches.
* **New-PasswordStatePassword** - Create a new password entry.
* **New-PasswordStateRandomPassword** - Use PasswordState to generate one or more random passwords for you based on various criteria.
* **Set-PasswordStatePassword** - Update an existing password entry.

### Example

![](/images/posts/powershell-module-for-clickstudios-passwordstate/PasswordState_example2.png)

### Summary

I hope you've found this post interesting and perhaps help spawn some ideas on how you could use this module in your own environment. Contributions to enhance the module are welcome.

<p style="text-align: center;">
  <a target="_blank" class="btn small" href="https://github.com/devblackops/PasswordState">PasswordState on GitHub→</a>
</p>

Cheers
