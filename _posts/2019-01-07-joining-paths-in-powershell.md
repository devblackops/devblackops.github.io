---
title: Joining Paths in PowerShell
date: 2019-01-07
featured-image: two-roads.jpg
excerpt: "Frequently in PowerShell, you'll be dealing with file paths and programmatically constructing them to either write or read files. There are a few different ways to build up file paths in PowerShell which I'll go over"
comments: false
categories: [PowerShell]
tags: [PowerShell, Join-Path]
---

Frequently in PowerShell, you'll be dealing with file paths and programmatically constructing them to either write or read files.
There are a few different ways to build up file paths in PowerShell which I'll go over below.

## Using a hard-coded string

It is very common to see file paths being created by specifying the exact, hard-coded path.

```powershell
$path = 'C:\mypath\to\foo.txt'
```

This is problematic for a few reasons though.
You'll notice that we're using `c:\` in the string.
This immediately limits the use of this to Windows as the concept of the `C:` drive only exists there.

In case you haven't heard, PowerShell is [cross-platform](https://blogs.msdn.microsoft.com/powershell/2016/08/18/powershell-on-linux-and-open-source-2/) now with version 6.
We need to start thinking about how our scripts will run if they are executed on macOS or Linux.
Assuming that they will only ever be executed on Windows will limit their usefulness, especially if we ever intend to publish it for others.

The other issue with this example is the use of backslashes `\`.
This may be the primary way to separate paths on Windows, but on Unix-like operating systems, the forward slash `/` is used.
In most cases, PowerShell will normalize this for you on whatever OS you're running on, and it is often forgotten that Windows **also** supports the forward slash `/` as a path separator, but this may not work in every scenario.
To help ensure our scripts work in all environments, it is a good practice to use `/` if manually constructing a folder or file path.

Also, if you need to access a path like `C:\mypath\to\foo.txt` on Windows or similar on macOS/Linux, it would be better to use a mix of environment and/or built-in PowerShell variables to make it more resilient.
In PowerShell 6, the new boolean variables `$IsWindows`, `$IsLinux`, and `$IsMacOS` will tell you what operating system you're on, and on Windows, we can rely on `$env:SYSTEMDRIVE` to return the system drive.
This is usually `C:\` but in rare cases, could be another drive letter.
On a Unix-like OS, we can use root `/`.
We can use these variables to determine the correct path to use depending on the operating system.

```powershell
if ($IsWindows) {
    $path = "$env:SYSTEMDRIVE/mypath/to/foo.txt"
} else {
    $path = '/mypath/to/foo.txt'
}
```

## Using Join-Path

PowerShell includes the cmdlet `Join-Path` for taking multiple paths and returning a single path.
This is a better method as `Join-Path` will ensure the correct path separator is used depending on the context.

The example below will return `C:\foo` on Windows.

```powershell
$path = Join-Path -Path $env:SYSTEMDRIVE -ChildPath 'foo'
```

## Joining three or more paths

Often, we'll run into situations where we need to join more than two paths together.
We **could** do something like:

```powershell
$path = "$path1/$path2/$path3"
```

or

```powershell
$path = Join-Path -Path $path1 -ChildPath "$path2/$path3"
```

or even worse:

```powershell
$path = Join-Path -Path $path1 -ChildPath (Join-Path -Path $path2 -ChildPath $path3)
```

None of these are particularly elegant though.

Starting in PowerShell 6, `Join-Path` has a new parameter called `-AdditionalChildPaths`.
This parameter takes a string array that you can use to include as many additional path sections as you need.
With this, we can utilize the built-in cmdlet and not rely on any manual string concatenation.

```powershell
$path = Join-Path -Path $path1 -ChildPath $path2 -AdditionalChildPaths ($path3, $path4)
```

These parameters also work positionally so you can skip specifying the parameters names if you desire.
This technically goes against established PowerShell style guidelines for explicitly using parameter names but for common cmdlets, it is generally accepted.

```powershell
$path = Join-Path $path1 $path2 $path3 $path4
```

## Dipping into .NET

One of the great things about PowerShell is the ability to dip into .Net when you need extra power or flexibility.
My new favorite method of constructing file paths is using .NET's `[System.IO.Path]` class and the `Combine()` method.
This method accepts two or more strings which it will combine in one operation and not rely on any manual string concatenation.

The great thing about this method is it works similar to PowerShell v6's `Join-Path` and the `-AdditionalChildPaths` parameter, but works on lower versions of PowerShell as well, making your script or module even more portable.

```powershell
$path = [IO.Path]::Combine($path1, $path2, $path3, $path4)
```

Happy ~~trails~~ paths :)
