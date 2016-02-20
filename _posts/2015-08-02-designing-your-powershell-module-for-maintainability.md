---
title:  Designing Your PowerShell Module for Maintainability
date:   2015-08-02
featured-image: posts/windows-powershell.png
excerpt: "If you have used PowerShell for any length of time, I'm sure you've started to amass a fair number of scripts and functions to automate all your various IT tasks. It is usually at this time that you start to look at creating your own modules to package up these pieces of code to make them more reusable for yourself and others. I'm not going to go into specifics on HOW to create PowerShell modules, there are plenty of resources for that out for that. Instead, I want to talk about designing your PowerShell module for maintainability."
comments: true
categories: [DevOps, DSC, PowerShell, VMware]
tags: [DevOps, DSC, PowerShell, VMware]
---

If you have used PowerShell for any length of time, I'm sure you've started to amass a fair number of scripts and functions to automate all your various IT tasks. It is usually at this time that you start to look at creating your own modules to package up these pieces of code to make them more reusable for yourself and others. I'm not going to go into specifics on HOW to create PowerShell modules, there are plenty of resources for that out for that. Instead, I want to talk about designing your PowerShell module for maintainability.

### Avoid the Monolithic .PSM1

You will probably see many examples on the internet showing this simple structure for your PowerShell module:

![](/images/posts/designing-your-powershell-module-for-maintainability/passwordstate4.png)

Looks simple right? Your module manifest file (.psd1) and all your functions in the .psm1 file. This is probably fine if your module consists of just one or two functions but this simple layout will start to bite you in the rear when you start adding more and more functions to your .psm1 file and you start committing these changes to your source control system of choice. Imagine combing through your .psm1 file to make a simple change when it has dozens or perhaps hundreds of functions in it. You can see that this starts to become unwieldy quickly.

### Breaking Up Your Module

A much more maintainable way to layout your module is to create a separate .ps1 file for each function. You can then dot source these functions in your .psm1 file and export any functions you want made public. This keeps your .psm1 file nice and clean and when extending your module, allows you to focus on each function individually. When you commit the module to source control, since each function is isolated to its own file, this also allows you to easily identify what has changed based on the modified date of each file.

### Dot Source Your Functions

![](/images/posts/designing-your-powershell-module-for-maintainability/passwordstate3.png)

### Module layout

![](/images/posts/designing-your-powershell-module-for-maintainability/passwordstate1.png)

![](/images/posts/designing-your-powershell-module-for-maintainability/passwordstate2.png)

Cheers
