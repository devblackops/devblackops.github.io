---
title: "How to Process File Paths from the Pipeline in PowerShell Functions"
date: 2018-06-05
featured-image: powershell-logo2.png
excerpt: "The correct way to write a PowerShell function that works with file paths from the pipeline requires some effort, but it will make your PowerShell scripts work more reliably."
comments: true
categories: [PowerShell]
tags: [PowerShell, Pipeline, Files]
---

The correct way to write a PowerShell function that works with file paths from the pipeline requires some effort, but it will make your PowerShell scripts work more reliably.

Suppose we want to write a function that counts the number of lines in a text file, and we want to pipe those files to our function. Cmdlets like Get-Item, Get-ChildItem, and Get-Content all accept input from the pipeline, but how do we write a function that behaves similarly to the core cmdlets? Let's see how we would go about creating our own function that supports this workflow.

[Read more at 4sysops.com](https://4sysops.com/archives/process-file-paths-from-the-pipeline-in-powershell-functions/)
