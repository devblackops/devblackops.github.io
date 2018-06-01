---
title: "Infrastructure Testing with Pester and the Operation Validation Framework"
date: 2018-05-31
featured-image: testing.jpg
excerpt: "If you've been using PowerShell for any length of time in the past few years you have undoubtedly heard of Pester.
If not, then you're probably living in a strange parallel universe where the Zune is still a thing.
In any case, Pester is THE testing framework for PowerShell and is a must-have tool in your Infrastructure Developer toolbox."
comments: true
categories: [Testing, PowerShell]
tags: [PowerShell, Infrastructure, Testing, Pester, OVF, Operation Validation]
---

If you've been using PowerShell for any length of time in the past few years, you have undoubtedly heard of Pester.
If not, then you're probably living in a strange parallel universe where the Zune is still a thing.
In any case, Pester is **THE** testing framework for PowerShell and is a must-have tool in your Infrastructure Developer toolbox.

I say Infrastructure Developer because that is what we are.
If you write production code to automate your infrastructure, then you are not a Systems Engineer or Administrator, a SharePoint Engineer or anything else, you are a developer.
**Full stop**.

The fact that we write PowerShell code that defines or runs IT infrastructure is not any different than a web developer using CSS, JavaScript, and HTML, or a full-stack ninja rockstar slinging micro-services written in Go on [Kubernetes](https://kubernetes.io/).

> Everything envolves working with code therefore **everyone** is a developer.
<br/><br/>- Sun Tzu

Your traditional developer working with C# or Java tests their code.
Your traditional Windows administrator using PowerShell to automate their jobs away (you won't) **SHOULD** test their code.
Even if you're not writing tests in [Pester](https://github.com/pester/Pester), [RSpec](http://rspec.info/), [SpecFlow](http://specflow.org/), etc, you are testing your code.
Or I should say, your **users are testing your code for you**.

## What about your Infrastructure?

Do you test your infrastructure to verify it is working the way you expect?
Are your services configured according to your specifications?
Your infrastructure is not a static object; never changing and forever in the state you expect.

**If you're not actively testing your infrastructure, don't worry, your users WILL let you know when it's not working :)**

>Things change. Always.
<br/><br/>- Abraham Lincoln

Servers get provisioned or deprovisioned, new applications come online, or old ones fade away into the sunset.
What about the gremlins chewing on the wires causing latency between services, or buggy code (cough...not yours of course) causing applications to crash?
What about that outage last week where you manually tweaked a setting but forgot to backport it into your DSC configuration?
All of these things create a living, breathing, dynamic environment.
**That environment must be tested to ensure your infrastructure reality matches your desired state.**

This is where tools like Pester and the Operation Validation Framework can help.

## Operation Validation?

You know what Pester is and know that you use it to test the functionality of your PowerShell scripts/modules
Did you know you can **also** use it to test your infrastructure?
When you think about it, all Pester is doing at the end of the day is comparing a value on the left (**your actual state**), to a value on the right (**your desired state**) and raising an alarm when these don't match.

#### Get-Answer.ps1

```powershell
function Get-Answer {
    param(
        [parameter(Mandatory)]
        [string]$Question
    )

    if ($Question -eq 'Answer to the Ultimate Question of Life, the Universe, and Everything') {
        42
    }
}
```

#### Get-Answer.tests.ps1

```powershell
describe 'Get-Answer' {
    context 'Correct output' {
        it 'Returns the correct value' {
            Get-Answer -Question 'Answer to the Ultimate Question of Life, the Universe, and Everything' | Should -Be 42
        }
    }
}
```



The test above is validating the output of our `Get-Answer` function. Now take a look at an infrastructure test:

#### os.services.tests.ps1

```powershell
describe 'Operating System' {
    context 'Service Availability' {
        it 'Eventlog is running' {
            $svc = Get-Service -Name Eventlog
            $svc.Status | Should -Be running
        }
    }
}
```

Looks similar to me 😊

## Operation Validation Framework

Now that we know we can use Pester to test our infrastructure, what do we do with these tests and how do we execute them?
What if we wanted to **version** these tests and **publish** them?
**Hey, that sounds like a PowerShell module!**

>Your ideas are intriguing to me and I wish to subscribe to your newsletter.
<br/><br/>- Sir Isaac Newton

This is where the [Operation Validation Framework](https://github.com/PowerShell/Operation-Validation-Framework) comes into play.
It is a PowerShell module that searches for Pester tests contained in a defined folder structure in your other PowerShell modules and ...wait for it... executes them with Pester.
That's it.
By just putting our Pester tests in a module, we can now version them, publish them, and execute them!

### Folder Structure

The Operation Validation Framework, or just OVF, expects Pester tests inside a known location in your module.
If you put Pester tests inside a `Diagnostics\Simple` or `Diagnostics\Comprehensive` folder under your module, OVF can find these and execute them. The `Simple` folder is intended for tests that are quick and non-intrusive to execute.
These tests could be executed every few minutes with little impact.
The `Comprehensive` tests would be for more involved and take longer to execute.
You’d probably run these every few hours or once a day.

- MyTestModule\
  - MyTestModule.psd1
  - Diagnostics\
    - Simple\
      - services.tests.ps1
      - logicaldisks.tests.ps1
    - Comprehensive\
      - performance.tests.ps1

As an example, let’s say we have a PowerShell module with the structure above.
This module includes the Pester tests below.
Notice that both Pester test scripts have parameters that define some default values.
Pester has this nifty feature where you can invoke a test script and inject in parameters to it.
This allows you to provide some sane defaults for your tests yet allow the user to override them if they need to.
OVF also supports this feature.
This means that you can write **generic** OVF modules designed to test a certain product or OS feature and publish them to the PowerShell Gallery!
Users can then download and execute these, overriding the default parameters if necessary to fit their environment.
We’d have common infrastructure tests that the whole community could use!

![Do you know what this means?](/images/posts/infrastructure-testing-with-pester-and-the-operation-validation-framework/1z122s.jpg)

#### services.tests.ps1

```powershell
param(
    $Services = @(
        'DHCP', 'DNSCache','Eventlog', 'PlugPlay', 'RpcSs', 'lanmanserver',
        'LmHosts', 'Lanmanworkstation', 'MpsSvc', 'WinRM'
    )
)

describe 'Operating System' {
    context 'Service Availability' {
        $Services | ForEach-Object {
            it "[$_] should be running" {
                (Get-Service $_).Status | Should -Be running
            }
        }
    }
}
```

![Service test results](/images/posts/infrastructure-testing-with-pester-and-the-operation-validation-framework/simpletestsresults.PNG)

#### logicaldisk.tests.ps1

```powershell
param(
    $FreeSystemDriveMBytesThreshold = 500,
    $FreeSystemDrivePctThreshold = .05,
    $FreeNonSystemDriveMBytesThreshold = 1000,
    $FreeNonSystemDrivePctThreshold = .05
)

describe 'Logical Disks' {

    $vols = Get-Volume | Where-Object { $_.DriveType -eq 'Fixed' -and -not [string]::IsNullOrEmpty($_.DriveLetter)}
    context 'Availablity' {
        $vols | ForEach-Object {
            it "Volume [$($_.DriveLetter)] is healthy" {
                $_.HealthStatus | Should -Be 'Healthy'
            }
        }
    }

    context 'Capacity' {
        $systemDriveLetter = $env:SystemDrive.Substring(0, 1)
        $sysVol = $vols | Where-Object DriveLetter -eq $systemDriveLetter
        $nonSysVols = $vols | Where-Object DriveLetter -ne $systemDriveLetter

        it "System drive [$systemDriveLetter] has $FreeSystemDriveMBytesThreshold MB and $('{0:p0}' -f $FreeSystemDrivePctThreshold) free" {
            ($sysVol.SizeRemaining / 1MB) -ge $FreeSystemDriveMBytesThreshold | Should -Be $true
            ($sysVol.SizeRemaining / $sysVol.Size) -ge $FreeSystemDriveThresholdPct | Should -Be $true
        }

        foreach ($volume in $nonSysVols) {
            $driveLetter = $volume.DriveLetter
            it "Non-System drive [$driveLetter] has greater than $FreeNonSystemDriveMBytesThreshold MB and $('{0:p0}' -f $FreeNonSystemDrivePctThreshold) free" {
                ($volume.SizeRemaining / 1MB) -ge $FreeNonSystemDriveThreshold | Should -Be $true
                ($volume.SizeRemaining / $volume.Size) -ge $FreeNonSystemDriveThresholdPct | Should -Be $true
            }
        }
    }
}
```

![Logical disk tests](/images/posts/infrastructure-testing-with-pester-and-the-operation-validation-framework/logicaldiskresults.PNG)

>Always remember that you are absolutely unique. Just like everyone else.
<br/><br/>- Mister Rogers

Now let’s see how to execute these same tests but using OVF.
Since our test module has been installed into `$env:PSModulePath`, OVF will find it, inspect it, and return a collection of tests.
These tests can then be executed with `Invoke-OperationValidation`.
Imagine having your monitoring system running the simple script below and throwing alerts if any of the Pester tests have failed.

```powershell
Import-Module OperationValidation
$tests = Get-OperationValidation -ModuleName MyTestModule
$results = $tests | Invoke-OperationValidation
$results
```

![Running OVF tests](/images/posts/infrastructure-testing-with-pester-and-the-operation-validation-framework/runovftest.PNG)

To execute the OVF tests and override the default parameters, we can use the `-Overrides` parameter.
We can also show the Pester output as well.
The cool thing about this framework is that you can develop a common module to test a certain technology and then tailor the settings per environment.

![Override OVF test parameters](/images/posts/infrastructure-testing-with-pester-and-the-operation-validation-framework/overrideovftest.PNG)

## Wrapping Up

Using Pester to test your infrastructure should become a common practice for IT administrators.
Everything is starting to be defined in code and like I said at the beginning, we are all developers now.
We may be coding infrastructure, but the basics of software development still apply.
Shouldn’t we be testing like a developer too?

## Further reading

- [https://sysnetdevops.com/2017/06/05/testing-infrastructure-with-pester/](https://sysnetdevops.com/2017/06/05/testing-infrastructure-with-pester/)

- [https://4sysops.com/archives/an-introduction-to-infrastructure-testing-with-powershell-pester/](https://4sysops.com/archives/an-introduction-to-infrastructure-testing-with-powershell-pester/)

- [http://www.brycematthew.net/powershell/pester/2017/04/13/Pester-Infrastructure-Testing.html](http://www.brycematthew.net/powershell/pester/2017/04/13/Pester-Infrastructure-Testing.html)

- [http://wragg.io/getting-started-with-pester-for-operational-testing/](http://wragg.io/getting-started-with-pester-for-operational-testing/)

By the way, the quote attributions in this post may be inaccurate. I can't know for sure. I didn't test them. ;)

Cheers