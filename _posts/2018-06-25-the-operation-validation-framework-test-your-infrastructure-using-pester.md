---
title: "The Operation Validation Framework: Test your infrastructure using Pester"
date: 2018-06-25
featured-image: azure-function-powershell.png
excerpt: "Knowing if your IT infrastructure is operating as it should is a fundamental task for any IT administrator. There are a plethora of tools and products available in the market to accomplish this task. I want to talk about another option that is free, simple, and uses PowerShell and Pester to perform the heavy lifting. This simple module is called the Operation Validation Framework."
comments: true
categories: [PowerShell]
tags: [PowerShell, Infrastructure, Testing, Pester, OVF, Operation Validation]
---

Knowing if your IT infrastructure is operating as it should is a fundamental task for any IT administrator. Plethoras of tools and products are available in the market to accomplish this task. I want to talk about another option that is free, simple, and uses PowerShell and Pester to perform the heavy lifting. This simple module is called the Operation Validation Framework.

The [Operation Validation Framework](https://github.com/PowerShell/Operation-Validation-Framework) (OVF) is a PowerShell module that uses [Pester](https://4sysops.com/archives/an-introduction-to-infrastructure-testing-with-powershell-pester/) tests as the basis for validating that your infrastructure is operating as it should. OVF is a simple PowerShell module that allows you to create Pester tests in a defined directory structure inside PowerShell modules. Packaging our tests inside a module provides them with versions, and we can publish them to NuGet repositories like the [PowerShell Gallery](https://www.powershellgallery.com/).

Read more at [4sysops.com](https://4sysops.com/archives/the-operation-validation-framework-test-your-infrastructure-using-pester/)
