---
title: "How to Run a PowerShell Script as a Windows Service"
date: 2018-06-01
featured-image: gears.png
excerpt: "If you have a PowerShell script you'd like to run constantly in the background and start up automatically after a reboot, the best option is to run it as a Windows service. I'll show you how to set this up using NSSM, the Non-Sucking Service Manager."
comments: true
categories: [PowerShell]
tags: [PowerShell, Windows Service]
---

If you have a PowerShell script you'd like to run constantly in the background and start up automatically after a reboot, the best option is to run it as a Windows service. I'll show you how to set this up using [NSSM](https://nssm.cc/), the Non-Sucking Service Manager.

## The Scenario

Most PowerShell scripts aim to run a task and then exit. You'll usually execute a script from the PowerShell console or perhaps trigger it periodically via the Windows Task Scheduler. However, you may want to run a script 24/7 and ensure it starts up again after a reboot or crash. To do this, the easiest option is to use [NSSM](https://nssm.cc/).

[Read more at 4sysops.com](https://4sysops.com/archives/how-to-run-a-powershell-script-as-a-windows-service/)
