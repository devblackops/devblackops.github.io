---
title: 9 Tips for Writing Better PowerShell Functions
date: 2019-12-07
categories: [PowerShell]
featured-image: tip-icon-3.jpg
excerpt: "PowerShell has a lot of functionality tucked away into functions that sometimes is not known, ignored, or forgotten about entirely. Let's talk about some basic things we can add to functions that will improve our scripts and ultimately make us better tool makers."
comments: true
hide_from_feed: false
tags: [PowerShell, Tips]
---

One of the most common tasks in PowerShell is writing PowerShell functions.
Functions are one of the basic building blocks we use to separate and abstract our code away.
Without them, our scripts would be just a tangled mess of `if` statements, `while` and `for` loops, and duplicated code.

Functions allow us to package our PowerShell logic into discreet blocks we can call, pass parameters to affect how they work, and reuse them so we can follow DRY (Don't Repeat Yourself) principals.

PowerShell has a lot of functionality tucked away into functions that sometimes are not known, ignored, or forgotten about entirely.
Let's talk about some basic things we can add to functions that mprove our scripts and ultimately make us better tool makers.

## TOC

- [Tip 1: Functions Should Do One Thing](#tip-1-functions-should-do-one-thing)
- [Tip 2: Functions Should Be Testable](#tip-2-functions-should-be-testable)
- [Tip 3: Functions Should Be Self-Contained](#tip-3-functions-should-be-self-contained)
- [Tip 4: Add Comment-Based Help](#tip-4-add-comment-based-help)
- [Tip 5: Use The PowerShell Function Naming Convention](#tip-5-use-the-powershell-function-naming-convention)
- [Tip 6: Leverage Advanced Functions](#tip-6-leverage-advanced-functions)
- [Tip 7: Support the Pipeline](#tip-7-support-the-pipeline)
- [Tip 8: Support -WhatIf If Making Changes](#tip-8-support--whatif-if-making-changes)
- [Tip 9: Support -Confirm if Making Changes](#tip-9-support--confirm-if-making-changes)

## Tip #1: Functions Should Do One Thing

First off, let's make one thing clear.
Functions should do one thing and one thing only.

> Give me a ping Vasili, one ping only please.
<br><br>- Capt. Marko Ramius - The Hunt for Red October

I've seen countless PowerShell functions that try to cram in entirely too much logic and end up being an unwieldy mess.
These large, unfocused functions end up being hard to understand as they have no clear purpose.
They can perform in strange ways, utterly unrelated at all to what the user _thinks_ the function does.

I'll admit, I do this myself sometimes (hey nobody's perfect).
This is especially true when you're writing code for the first time to perform a new task.
It's easy to fall into the trap of handling this one edge case here, this other edge case there, maybe output this variable if _these_ set of conditions are true, etc.

We must recognize when this happens, and to correct the situation as soon as possible.
If we don't, we'll end up struggling to support an unmaintainable function, our productivity suffers, and the users of our code become frustrated at the lack of focus.

## Tip #2: Functions Should Be Testable

In short, single-purpose PowerShell functions are easier to write tests for in tools like [Pester](https://github.com/pester/Pester).
We can create tests for the (hopefully one or just a few) different scenarios of expected input parameters and validate the function produced the expected output.
If the function does too many things, writing unit tests becomes difficult or almost impossible.

It's better to have a handful of small, discreet functions with quality unit tests than one large function with no or poor unit tests.

## Tip #3: Functions Should Be Self-Contained

It's almost a certainty that your PowerShell function is working with variables in some way.
A good practice is to supply the function with all the **external** variables it may need to perform its task as parameters into the function.

If our function only **reads** external variables, it's a good idea to add parameters to the function with the default value being the external variable.

A big reason to do this is it helps make writing unit tests for functions easier.
We can confidently test a function in isolation, and verify the outputs if we supply all the required information directly into the function.

When functions access external variables and make assumptions on their contents, hard to troubleshoot bugs can occur if those variables had their contents modified but another function.

## Tip #4: Add Comment-Based Help

PowerShell has this excellent feature called [comment-based help](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_comment_based_help?view=powershell-6).
Use it to provide users of your code clear guidance on what it does and how to use it.

When PowerShell parses your function, the comment-based help contained within is accessible via the builtin [Get-Help](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/get-help?view=powershell-6) cmdlet.
The help text for a function doesn't need to be a novel, but clear and accurate help on what the function does, descriptions for each parameter, and useful examples for how to use the function is one of the best ways to delight the users of your function.
Conversely, having no or inaccurate help is one of the easiest ways to frustrate the users of your software with the genuine possibility of them stopping to use it at all.

## Tip #5: Use The PowerShell Function Naming Convention

PowerShell uses a `Verb`-`Noun` syntax for functions and cmdlets.
You can see the list of approved verbs with descriptions about what they are intended for by running the `Get-Verb` command.

A big reason for the approved verb list is consistency.
The creators of PowerShell wanted it to provide a consistent experience to the user.
This consistently also enhances PowerShell's readability.

If a function is called `Get-IpAddress`, there is little ambiguity as to that the function does.
It returns an IP address.
It **does not** set the IP address or otherwise make changes to the system.

If we wanted to set the IP address, it would be intuitive to have a `Set-IpAddress` function.

I've seen many custom PowerShell functions use the `Get` verb but internally make non-obvious changes to the system.
This not only causes confusion because you're wondering: "Hey! I just got my IP address. Why did my recycle bin get cleared out?"
It also has the potential to cause harm, as the actions of the function does not match what the user expects.

**This is a big no-no in PowerShell**.

## Tip #6: Leverage Advanced Functions

PowerShell gives you a excellent set of features you can use in functions for practically free **if** you make them [advanced functions](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions_advanced?view=powershell-6).
By adding the [[CmdletBinding()]](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions_cmdletbindingattribute?view=powershell-6) attribute to a function, you now have access to a set of [common parameters](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_commonparameters?view=powershell-5.1) you can utilize for things like:

- Writing verbose messages
- Supporting `-Confirm` and `-WhatIf` modes
- Parameter validation
- Support input from the pipeline
- [Advanced parameters](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions_advanced_parameters?view=powershell-6)

When creating new functions, it is a good practice to make them advanced functions as a matter of course.
This allows you to support the features above easily should you need them.

## Tip #7: Support the Pipeline

This is an extension of [Tip #6](#tip-6-leverage-advanced-functions), but I feel it deserves its own section.
If you're adhering to [Tip #1](tip-1-functions-should-do-one-thing) and writing functions that do one thing only, then supporting the pipeline is an important feature to add so functions can be chained together to perform more complex logic.

Advanced functions add support for the [ValueFromPipeline](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions_advanced_parameters?view=powershell-6#valuefrompipeline-argument) argument attached to parameters via the [Parameter](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions_advanced_parameters?view=powershell-6#parameter-attribute) attribute.

Adding this argument indicates to PowerShell that the value of the parameter can come from a pipeline object.
This allows you to stream the value of the parameter from the output of another function/cmdlet.

For more information about the PowerShell pipeline, check out the [about_pipelines](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_pipelines?view=powershell-6) help doc or run `Get-Help about_pipelines` from PowerShell itself.

## Tip #8: Support -WhatIf If Making Changes

PowerShell's support of the `-WhatIf` switch parameter is analogous to `--dry-run` or `--noop` in other tools.
When specifying the `-WhatIf` switch, what you're essentially telling PowerShell is: "Tell me what you're going to do, but don't _actually_ do it."

It's a great tool to have when running PowerShell interactively to validate a series of actions that could potentially have serious effects **without actually making them**.

Imagine you needed to run a command to delete files from a directory recursively.
You want to delete all `.log` files from the `C:\tmp` directory but also want to be extra careful that you don't inadvertently delete other files, so you add the `-WhatIf` switch to `Remove-Item` like so:

```powershell
Get-ChildItem -Path C:\tmp -File *.log -Recurse | Remove-Item -WhatIf
```

With this, you can see all the files that `Remove-Item` **would have** deleted if you hadn't provided the `-WhatIf` switch.
After validating the files displayed, you safely remove the `-WhatIf` switch and rerun the command to remove the files.

`-WhatIf` is only supported in advanced functions, so it’s another reason to implement [Tip #6](#tip-6-leverage-advanced-functions). When authoring functions that affect the system in some way, add `-WhatIf` support via the `SupportsShouldProcess` argument on the [[CmdletBinding()]](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions_cmdletbindingattribute?view=powershell-6) attribute.

Check out [Boe Prox's](https://twitter.com/proxb) article about [Adding -WhatIf Support to Functions and Scripts](https://learn-powershell.net/2013/04/30/scripting-games-2013-use-of-supportsshouldprocess-in-functionsscripts/).

## Tip #9: Support -Confirm if Making Changes

Related to [Tip #8](tip-8-support--whatif-if-needed), the `-Confirm` switch indicates to PowerShell to pause before every action and display an interactive prompt asking you to **confirm** the action before it executes.
It will do this for every object in the pipeline, allowing you to inspect the item before continuing.

Just like with `-WhatIf` support, adding `-Confirm` support is only possible with advanced functions, so [Tip #6](#tip-6-leverage-advanced-functions) still applies.

Check out [vex32's](https://twitter.com/vexx32) excellent article about [adding support for -Confirm](https://vexx32.github.io/2018/11/22/Implementing-ShouldProcess/) to your functions.

## Closing

One of the problems with making a list of tips is knowing when to stop.
There are many more tips I **could** have added about writing functions or even a list of things to definitely **not** do.
Those will have to wait for another day.

Cheers!

_Icon courtesy of <a target="_blank" href="https://icon-library.net/icon/tip-icon-3.html">Tip Icon #388700</a>_
