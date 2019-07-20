---
title: Using PoshBot Middleware for Rate-Limiting Notifications
date: 2019-07-15
featured-image: poshbot_logo_thumb_256.png
excerpt: "Somone in the PowerShell Slack workspace asked if in PoshBot, he could notify users if users send over (x) amount of messages in (y) amount of time, and to suggest using a Slack thread. Here's how you can use PoshBot middleware to accomplish that."
comments: false
categories: [PoshBot, PowerShell ]
tags: [PoshBot, PowerShell, Slack]
---

Recently, someone in the **#ChatOps** channel of the [PowerShell Slack](http://aks.ms/psslack) workspace asked if it's possible to use [PoshBot](https://github.com/poshbotio/PoshBot) to send a message recommending people to use [Slack threads](https://get.slack.help/hc/en-us/articles/115000769927-Use-threads-to-organize-discussions-) if they send over (x) amount of messages in (y) amount of time.
I suppose he wanted to encourage threaded conversations to reduce the clutter in his Slack workspace.
Here's the solution I sent him that I adapted from a [Stack Overflow question about rate-limiting](https://stackoverflow.com/questions/667508/whats-a-good-rate-limiting-algorithm).
What we'll use to track user message rate is known as the [token bucket](https://en.wikipedia.org/wiki/Token_bucket) algorithm.

## PoshBot Middleware

PoshBot has the concept of [middleware hooks](http://docs.poshbot.io/en/latest/guides/middleware/#middleware-hooks), which is the ability to execute custom PowerShell scripts during certain events in the command processing lifecycle.
These hooks can do pretty much anything you want.
After all, they are just PowerShell scripts.
If you follow the conventions outlined in the documentation, they are pretty straightforward to set up and can extend the utility of our ChatOps tooling.

## Middleware Hook Stages

There are **six** different stages that middleware can execute.
Middleware can modify the command received, the response back to the backend, or even to drop the message entirely and not allow it to execute.
You pick the appropriate stage depending on what your middleware is doing.

| Name | Description |
|------|-------------|
| PreReceive   | Runs before PoshBot "receives" the message from the [backend](http://docs.poshbot.io/en/latest/tutorials/backend-development/overview/) |
| PostReceive  | Runs after the message is "received" from the backend, parsed, and matched with a registered bot command |
| PreExecute   | Runs before a command is executed |
| PostExecute  | Runs after a command has been executed but before responses are sent to the backend |
| PreResponse  | Runs before responses are sent to the backend |
| PostResponse | Runs after responses have been sent to the backend |

## Adding the Middleware Hook

Middleware hooks are added to your [bot configuration](http://docs.poshbot.io/en/latest/guides/configuration/) under the property called `MiddlewareConfiguration`.
For the rate-limiting example I created, we're going to use the `PreReceive` stage because this middleware is intended to count normal messages occurring in Slack, not necessary just bot commands.
All the other stages run **after** a message has been parsed and matched to the bot command.
If we used any other stage, we'd only be measuring the rate of bot commands, not normal Slack messages.

In your bot configuration `.psd1` file, add the following to the `MiddlewareConfiguration` property.
Adjust the hook name and path as desired.

```powershell
@{
    #
    # Other sections omitted for brevity
    #
    MiddlewareConfiguration = @{
        PreReceive = @{
            Name = 'RateLimiter'
            Path = 'C:/Users/Brandon/.poshbot/middleware/rate_limiting_notice.ps1'
        }
        # PostReceive = @{
        #     Name = ''
        #     Path = ''
        # }
        # PreExecute = @{
        #     Name = ''
        #     Path = ''
        # }
        # PostExecute = @{
        #     Name = ''
        #     Path = ''
        # }
        # PreResponse = @{
        #     Name = ''
        #     Path = ''
        # }
        # PostResponse = @{
        #     Name = ''
        #     Path = ''
        # }
    }
}
```

Now let's look at `rate_limiting_notice.ps1` and go through each section.

### rate_limiting_notice.ps1

> The full script is found in this [GitHub gist](https://gist.github.com/devblackops/2b02fbb946a421de6efb5b9c8ce7d79b).

PoshBot middleware hooks are just standard PowerShell scripts, but PoshBot expects **two** parameters to be available and passes specific objects to them.

`$Context` is a PowerShell object containing a ton of information about the incoming message received from the backend. Who sent the message, what channel it was in, the raw JSON message from the backend, etc.
Our middleware needs to accept this object as the first parameter to the script.

`$Bot` is the main PoshBot instance object.
It is essentially a PowerShell class instance with a bunch of methods implementing all the bot logic.
Our middleware is given access to this object so we can perform deep modification of PoshBot internals.
**Remember, with great power comes great responsibility**.

```powershell
<#
.SYNOPSIS
    Suggest Slack threads for talkative users.
.DESCRIPTION
    This middleware tracks how many messages (x) users send per (y) amount of time.
    If a user goes over the threshold, we'll send a message suggesting that Slack threads should be used.
.NOTES
    Based on https://stackoverflow.com/questions/667508/whats-a-good-rate-limiting-algorithm
#>
param(
    $Context,
    $Bot
)
```

This next section is where we'll tell PoshBot to log a message that this middleware hook is starting and defining our rate-limiting values.
We'll also pull out the calling user ID from the context object.
We define our rate-limiting window in seconds but to allow greater precision for the actual measurements, we'll use milliseconds internally.

We also need to be sure we DON'T measure messages already in a threaded conversation, or to count other messages PoshBot receives about updates to threaded conversations.
If we don't exclude these, our rate-limiting won't work correctly and we'll pester people to use threaded conversations when they already are and that would be...awkward.

```powershell
$Bot.LogDebug('Beginning message ratelimit middleware')

# We'll allow (5) messages per user in a (60) second window before suggesting threads
$maxMsgs    = 5
$timePeriod = 60

$userId       = $Context.Message.From
$timePeriodMS = $timePeriod * 1000

# Only measure messages NOT already in a thread
# This middleware hook stage also receives extra messages whenever a user replies in a thread
# We need to ensure we DON'T count these against the rate-limiting
$unThreadedMsg = (
    ([string]::IsNullOrWhiteSpace($Context.Message.RawMessage.thread_ts) -and
    ($Context.Message.RawMessage.type -eq 'message' -and $Context.Message.RawMessage.subtype -ne 'message_replied'))
)
```

Next, assuming we're processing an **unthreaded** message, we'll either load up a tracking object or create a new one if it doesn't exist.
We're storing this data as a `CLIXML` file, so we need to use `Import-Clixml` to retrieve the object.
This tracker is a hashtable with the user ID as the key, and a hashtable containing the user's current message allowance and the last time they sent a message as the value.

```powershell
if ($unThreadedMsg) {
    # Load the tracker
    $trackerPath = Join-Path $Bot.Configuration.ConfigurationDirectory 'msg_ratelimiting_tracking.clixml'
    if (Test-Path $trackerPath) {
        $tracker = Import-Clixml $trackerPath
    } else {
        $tracker = @{
            $userId = @{
                Allowance   = $maxMsgs
                LastMsgTime = [datetime]::UtcNow
            }
        }
    }

```

Next, we'll get the current time and determine how many milliseconds it's been since the user last sent a message.
This value is then used to calculate our bucket allowance.

```powershell
$now        = [datetime]::UtcNow
$timePassed = ($now - $tracker[$userId].LastMsgTime).TotalSeconds
$tracker[$userId].LastMsgTime = $now
$tracker[$userId].Allowance  += $timePassed * ($maxMsgs / $timePeriodMS)
```

We now need to look at our allowance and determine if we've breached the rate limit set.
If we have `<1` allowance, then we send a friendly message back to Slack information the user that perhaps they should use Slack threads.
We do this by creating a `Response` object, which is a class internal to PoshBot that represents a message we want to send to the backend chat network.
We then reset the user's allowance so we won't keep on sending this message unless they breach the limit again.
Lastly, we'll save this data back to disk with `Export-Clixml`.

```powershell
if ($tracker[$userId].Allowance -lt 1.0) {
    $Bot.LogDebug("User [$userId] has breached ratelimit of [$maxMsgs] messages in [$timePeriod)] seconds. Sending thread reminder response")
    $response                 = [Response]::new()
    $response.To              = $Context.Message.To
    $response.MessageFrom     = $Context.Message.From
    $response.OriginalMessage = $Context.Message
    $mentionUser = "<@$($Context.Message.From)>"
    $text = "Hey $mentionUser, we noticed you have a lot to say. Perhaps creating a Slack thread would be useful."
    $response.Data = New-PoshBotTextResponse -Text $text -AsCode
    $Bot.SendMessage($response)

    $Bot.LogDebug('Sending thread reminding response')

    # Reset so we don't send again until they breach the limit again
    $tracker[$userId].Allowance = $maxMsgs
} else {
    $tracker[$userId].Allowance -= 1.0
}

$tracker | Export-Clixml -Path $trackerPath
```

Finally, we'll close out the *if/else* statement from above and log a debug message if we didn't need to measure this message at all.
We'll then return the command context to PoshBot.
Returning the `$Context` object to PoshBot tells it to continue with executing any other middleware hooks.
If we wanted to tell PoshBot to stop processing this message, we return nothing from the script.

```powershell
} else {
    $Bot.LogDebug("Ignoring message. It's already in a threaded conversation.")
}

# Return context back for any subsequent middleware
$Bot.LogDebug('Ending message ratelimit middleware')
$Context
```

## Summary

> The full script is found in this [GitHub gist](https://gist.github.com/devblackops/2b02fbb946a421de6efb5b9c8ce7d79b).

I hope this post was informative and highlighted the power and flexibility you have with PoshBot middleware hooks.
I'm sure this script didn't account for some edge cases and may even contain a bug or two, but I'll leave that as an exercise for the reader.

Cheers
