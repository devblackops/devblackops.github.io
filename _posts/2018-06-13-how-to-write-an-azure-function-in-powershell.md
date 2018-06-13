---
title: "How to Write an Azure Function in PowerShell"
date: 2018-06-13
featured-image: azure-function-powershell.png
excerpt: "Serverless computing, or the ability to execute code without having to manage the underlying resources, is all the rage these days. Can PowerShell join in on the fun? Yes it can! I'll show you how to use PowerShell to create an Azure Functions app and deploy a PowerShell-based function."
comments: true
categories: [PowerShell, Azure]
tags: [PowerShell, Azure, Azure Function, Serverless]
---

Serverless computing, or the ability to execute code without having to manage the underlying resources, is all the rage these days. Can PowerShell join in on the fun? Yes it can! This article will show you how to use PowerShell to create an Azure Functions app and deploy a PowerShell-based function.

## What Are Azure Functions?

Azure Functions is a computing model in Microsoft Azure that allows you to execute small pieces of code or functions in response to events. There is no server infrastructure for you to manage, hence the term "serverless."

At the end of the day, a server somewhere runs your code, but you needn't worry about it. The benefit of Azure Functions is that you just need to worry about the problem at hand, not the underlying infrastructure. This frees you from wasting extra cycles on needless maintenance tasks like OS upgrades and patching.

Just write the code to do your thing and move on. The consumption-based [billing plan](https://docs.microsoft.com/en-us/azure/azure-functions/functions-scale) only bills you for [per-second resource consumption and the number of executions](https://azure.microsoft.com/en-us/pricing/details/functions/). With the generous free grant of 1 million executions and 400,000 GB seconds a month, there is also a good chance your function will be free or nearly free.

[Read more at 4sysops.com](https://4sysops.com/archives/how-to-write-an-azure-function-in-powershell/)
