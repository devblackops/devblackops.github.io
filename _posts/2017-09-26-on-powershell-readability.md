---
title:  PowerShell Readability - Why being verbose and explicit is better than clever and obtuse
date:   2017-09-26
featured-image: posts/on-powershell-readability/opinion.jpg
excerpt: "I recently had to track down why a PowerShell script wasn't running correctly in production.
It apparently wasn't working for weeks and nobody noticed until now.
I didn't write this script but I knew of it's existence, still, I wasn't familiar with the code.
The author of the script wasn't immediately available so I started looking into the issue.
Never mind why the script broke or why it took weeks for anyone to notice :)
This post is about my experience looking at the script as a first time maintainer/troubleshooter of it."
comments: true
categories: [PowerShell]
tags: [PowerShell, Maintainability]
---

I recently had to track down why a PowerShell script wasn't running correctly in production.
It apparently wasn't working for weeks and nobody noticed until now.
I didn't write this script but I knew of it's existence, still, I wasn't familiar with the code.
The author of the script wasn't immediately available so I started looking into the issue.
Never mind why the script broke or why it took weeks for anyone to notice :)
This post is about my experience looking at the script as a first time maintainer/troubleshooter of it.

Essentially, this fairly small script deletes users accounts from Active Directory.
It only deletes accounts that have been disabled, and then only accounts that have not logged in in over 90 days.
This is a simple cleanup script for Active Directory. OK, got it.

So first off, it takes some parameters. This is what they look like:

```powershell
Param(
  [Boolean] $Test           = $True,
        [Int]     $Limit          = 10
)
```

Huh, spacing is a little weird. Looks like a mix of tabs and spaces.
Yay!
There is a `[boolean]` `$Test` parameter.
I think this is to test the script but it's not immediately clear.
The comments above the `param()` block don't state what `$Test` does and they aren't in [Comment-Based help](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_comment_based_help?view=powershell-5.1) format so I'll get no assistance from `Get-Help`.
Adding `[-WhatIf]` support would be a much better way to support this scenario **(especially since we're dealing with deleting accounts from Active Directory)**!
Same goes for `$Limit`.
I can assume this will limit how many accounts the script will delete at a time but I can't be sure. Moving on.

There are then a few variables defined like `$strGroup` (which is a group name for which its members will NEVER be deleted) and then a function called `Write-Log()`.
Nothing special there. Then I come to this:

```powershell
$GrpMembers = (Get-ADGroupMember $strGroup | Select samAccountName, distinguishedName)
If (($GrpMembers).count -EQ 0) {
  $strMessageText = ""
   write-Log $strMessageText
   $strMessageText = "There are no members of the $($strGroup)"
   write-Log $strMessageText
   $RC = 98
   Throw
}
```

It's obvious we're getting the members of `$strGroup` and checking if the count is `0`. But why is there a `throw` statement there? What does `$RC=98` do? I don't know and the comments above this block don't tell me either. Moving on.

We then add the members of `$GrpMembers` to a `hashtable` so we can quickly search the hashtable for a key rather than searching the `$GrpMembers` array. This is good. Searching a `hashtable` is extremely quick and efficient compared to searching arrays.

```powershell
$Exclusions = @{}
$GrpMembers | % {
   $sa = $_.samAccountName.tostring()
   $dn = $_.distinguishedName.tostring()
   $strMessageText = "Adding $($sa) with $($dn)"
   write-Log $strMessageText
   $Exclusions.Add($sa , $dn)
}
```

We then get to this:

```powershell
[ScriptBlock]$Filter = {(((LastLogonTimeStamp -Lt $TestDate) -Or -Not(LastLogonTimeStamp -Like "*")) -And (WhenCreated -Lt $TestDate) -And (WhenChanged -Lt $WhenChangedTestDate) -And (userAccountControl -BAnd 0x2) -And -Not(msExchUserHoldPolicies -Like "*") -And (-Not(msExchRecipientTypeDetails -Like '*') -Or (msExchRecipientTypeDetails -Eq '1') -OR (msExchRecipientTypeDetails -Eq '2147483648') -OR (msExchRecipientTypeDetails -Eq '6') -OR (msExchRecipientTypeDetails -Eq '128')) -AND -Not(samAccountName -Like "krbtgt*") -AND -Not(Name -Like "HealthMailbox*"))}
$colUsers = (Get-ADUser -Properties LastLogonTimeStamp, DisplayName, Description, msDS-AuthenticatedAtDC, msExchRecipientTypeDetails, msExchUserHoldPolicies, WhenChanged, WhenCreated -Filter $Filter)
```

Thankfully there is a helpful comment above this telling me this will filter out users that we don't want to delete.
But is this logic right?
It's extremely hard for a human to parse and determine if all the `-and` and `-or` statements are correct.
Is there a logic problem here and we're filtering **too** many users or **not enough**?
Honestly I don't know.
I had to spend a few minutes breaking this line into multiple statements to get my head around the logic.

Next is the meat of the script which processes our collection of users and determines if they should be deleted and.....wait for it..... deletes them.

```powershell
$colUsers | % {
   $strUser = $_.samAccountName
   If (-Not($Exclusions.$($strUser))) {
      If (($_.LastLogonTimeStamp -like "*") -And -Not($_.LastLogonTimeStamp -eq $Null)) {

         $LastLogon = [DateTime]($_.LastLogonTimeStamp)

         ($strUser."msDS-AuthenticatedAtDC" | sort -Unique) | % {
            ($_.Remove($_.IndexOf(",")).replace("CN=",$null)) | % {
               $DC = $_
            # Get the LastLogon attribute from the DC

               Write-Output "Starting check for $strUser on $DC"
               Try {$DCLastLogon = [DateTime](Get-ADUser $strUser -Properties LastLogon -Server $DC -ErrorAction SilentlyContinue).LastLogon}
               Catch {Return}
               Write-Host "Checking $DC for user $strUser with date $LastLogon - Found $DCLastLogon"

            # Get the LastLogon from the DC is not $Null and newer than the LastLogonTimeStamp, then use it instead.
               If (($($DCLastLogon) -GT $($LastLogon)) -And ($($DCLastLogon) -NE $Null)) {Write-Host "$DCLastLogon is more recent than $($LastLogon)" ; $LastLogon = $([DateTime]$DCLastLogon)}
            }
         }

         #Set LastLogonTimeStamp to current year for a reportable format
         $LastLogon = ([DateTime]($LastLogon)).addyears(1600)

         $strMessageText = "$($strUser) - LastLogon = $($LastLogon) and TestDate = $($TestDate)"
         write-Log $strMessageText
      }

         #############################################################################
         #                                                                           #
         # If we're not in "Test" mode and the last logon is older than the date to  #
         # test against, and the limited number of users have not been deleted then  #
         # then delete the user.                                                     #
         #                                                                           #
         #############################################################################

      If ((($LastLogon -Lt $TestDate) -OR (-Not($_.LastLogonTimeStamp -like "*") -And ([DateTime]$_.whenCreated -LT $TestDate))) -And ($Count -LT $Limit))   {

         $Count = $Count + 1

         $User = (Get-ADUser $strUser -Properties *)
         #write-output "AD User = $User"

         ($user.propertynames) | % {$MailText +=  "$($_): `n" ; $MailText +=  "`t$($User.$_)`n"}

         SendMail
         $MailText = $Null

         # Delete user account
         $strMessageText = "($($_.Name)) removed"
         write-Log $strMessageText
         Write-Output "Going to delete [$User]"
         If (-Not($Test)) {Remove-ADObject $($User) -Recursive -Confirm:$False}
         $User = $Null
      }
   }
   Else {
      $strMessageText = "Ignoring user $($_.Name) - Found in exclusions group."
      write-Log $strMessageText
   }
}


Exit $RC
```

There are quite a number of things funky with this big block of code but I'll just list the ones that give me the most grief.

#### 1. Nested `for` loops using the `%` alias and `$_`
It is very hard to keep track of which variable (and in which scope) you are referencing using `$_` is nested loops.
This is generally not a problem when doing simple things like:

```powershell
$myCollection | % {
    $_ | Do-Something
}
```

As soon as you start nesting loops using `%` or `Foreach-Object` and `$_` you run the risk of confusing your future self, or someone else who needs to maintain your code (like me).
It's always better to be explicit and use named variables and iterators when using loops.
When possible, I prefer this syntax instead:

```powershell
foreach($item in $myCollection) {
    $item | Invoke-Something
  
    foreach ($thing in $item.things) {
        $thing | Invoke-SomethingElse
    }
}
```

#### 2. Complex `If` statements

```powershell
If ((($LastLogon -Lt $TestDate) -OR (-Not($_.LastLogonTimeStamp -like "*") -And ([DateTime]$_.whenCreated -LT $TestDate))) -And ($Count -LT $Limit))   {}
```
Every condition in an `If` statement takes a little brain power and memory to evaluate.
The more you chain together, the more likely you'll overrun a buffer in your head and have to start from the beginning.
Add in distractions like office noise, desktop / phone notifications, etc, the more likely you'll take your eyes off the screen.
The second you do that, you've lost your place parsing the statement and will have to start over.

#### 3. Not using `-WhatIf`

<blockquote class="twitter-tweet" data-lang="en"><p lang="en" dir="ltr">Add -WhatIf support to your <a href="https://twitter.com/hashtag/PowerShell?src=hash&amp;ref_src=twsrc%5Etfw">#PowerShell</a> scripts. It’s like having a DD at the bar. You’ll have a good time, but won’t go to jail at the end.</p>&mdash; Brandon Olin (@devblackops) <a href="https://twitter.com/devblackops/status/913284098617098240?ref_src=twsrc%5Etfw">September 28, 2017</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

```powershell
If (-Not($Test)) {Remove-ADObject $($User) -Recursive -Confirm:$False}
```

PowerShell gives you some great things for free or little cost.
Once of those is advanced functions and common parameters.
Anytime you write a script that will make changes to the environment, you should add `-WhatIf` support.
This script included _sort of_ equivalent functionality with the `$Test` parameter but it wasn't immediately clear and wasn't documented.
[Stephen Owen](https://twitter.com/FoxDeploy) has an excellent post on using `-WhatIf` the [right way](https://foxdeploy.com/2014/09/04/adding-whatif-support-to-your-scripts-the-right-way-and-how-you-shouldnt-do-it/) that you should check out.

#### 4. No Verbose or Debug messages

Again, Powershell gives you some great things for free. Simply adding `[cmdletbinding()]` to this script would give us access to `Write-Verbose` and `Write-Debug` amongst other things. For each block of code that does a discrete _thing_, it's helpful to have a `Write-Verbose` or `Write-Debug` statement telling us what this block of code is about to do, or what it just did and here are the results. You can read more about the `[cmdletbinding()]` attribute [here](https://blogs.technet.microsoft.com/heyscriptingguy/2012/07/07/weekend-scripter-cmdletbinding-attribute-simplifies-powershell-functions/), [here](https://blogs.technet.microsoft.com/poshchap/2014/10/24/scripting-tips-and-tricks-cmdletbinding/), and [here](https://4sysops.com/archives/powershell-advanced-functions-the-cmdletbinding-and-parameter-attribute/).

There are a few others but they mostly come down to semantic issues.

The funny thing is, in the end, the script was working fine.
No issues at all.
Working as designed :)
The problem was further up the chain in another process this script relies on.

In a future post I'll show a modified version of this script that improves upon the issues I've stated above.
The goal is readability and maintainability.
Not by PowerShell, but by us meat sacks.
When things are broken, you don't want to be spending precious time just figuring out **what** is going on.
Your code should be clear in its purpose and be written in such a way as to help with testing/debuging when things go south.
