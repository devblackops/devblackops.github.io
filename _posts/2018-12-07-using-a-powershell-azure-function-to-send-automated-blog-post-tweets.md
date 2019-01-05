---
title: Using a Powershell Azure Function to Send Automated Blog Post Tweets
date: 2018-12-07
featured-image: powershell_plus_twitter.png
excerpt: If you follow me on Twitter, you would have probably noticed that I occasionally send out tweets from random previous blog posts. I don’t want to have to remember to send these manually, and after reading how Josh King does it in his automated blog archive tweets article, I thought I’d add my spin on it. For my implementation, I’m going to use an Azure Function as well as a bit of blob storage to keep track of previous tweets. This way, I don’t depend on my local computer being up, and I can keep track of what posts I’ve already tweeted out, so I don’t repeat them.
comments: true
categories: [PowerShell]
tags: [PowerShell, Azure, Twitter, Blogging]
---

If you follow me on [Twitter](https://twitter.com/devblackops), you would have probably noticed that I occasionally send out tweets from random previous blog posts.
I don’t want to have to remember to send these manually, and after reading how [Josh King](https://twitter.com/WindosNZ) does it in his [automated blog archive tweets](https://king.geek.nz/2018/05/30/automatic-blog-archive-tweets/) article, I thought I’d add my spin on it.
For my implementation, I’m going to use an [Azure Function](https://azure.microsoft.com/en-us/services/functions/?&OCID=AID719825_SEM_d6ITB4fz&lnkd=Google_Azure_Brand&gclid=EAIaIQobChMIsuXiz62M3wIVmP5kCh33dgTREAAYASAAEgKnYfD_BwE) as well as a bit of blob storage to keep track of previous tweets.
This way, I don’t depend on my local computer being up, and I can keep track of what posts I’ve already tweeted out, so I don’t repeat them.
An example of one of these automated tweets is below:

> All the code for this process can be found in the [GitHub repo](https://github.com/devblackops/blog-archive-tweeter-example).

<div align="center">
    <blockquote class="twitter-tweet" data-lang="en"><p lang="en" dir="ltr">From the blog archive: Infrastructure Testing with Pester and the Operation Validation Framework<a href="https://t.co/1JGELPKtko">https://t.co/1JGELPKtko</a><a href="https://twitter.com/hashtag/PowerShell?src=hash&amp;ref_src=twsrc%5Etfw">#PowerShell</a> <a href="https://twitter.com/hashtag/Infrastructure?src=hash&amp;ref_src=twsrc%5Etfw">#Infrastructure</a> <a href="https://twitter.com/hashtag/Testing?src=hash&amp;ref_src=twsrc%5Etfw">#Testing</a> <a href="https://twitter.com/hashtag/Pester?src=hash&amp;ref_src=twsrc%5Etfw">#Pester</a> <a href="https://twitter.com/hashtag/OVF?src=hash&amp;ref_src=twsrc%5Etfw">#OVF</a> <a href="https://twitter.com/hashtag/OperationValidation?src=hash&amp;ref_src=twsrc%5Etfw">#OperationValidation</a></p>&mdash; Brandon Olin (@devblackops) <a href="https://twitter.com/devblackops/status/1065853467795775488?ref_src=twsrc%5Etfw">November 23, 2018</a></blockquote>
<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>
</div>

<!-- ![Automated Tweed Screenshot](../images/posts/using-a-powershell-azure-function-to-send-automated-blog-post-tweets/automated-tweet-screenshot.png) -->

## TL;DR

This blog post tweeter works by consuming a JSON feed of previous blog posts, selecting one at random, generates a [Bitly](https://bitly.com/) link to the post, then sends the tweet.
A record of this tweet is then stored in Azure Storage, so subsequent invocations of the Function don't re-send the same post until all available posts have been tweeted out.
Once all available posts have been tweeted, the tracker is reset.
For all the details about how this process works keep reading.

## Blog Post JSON feed

I use the static site generator [Jekyll](https://jekyllrb.com/) for my blog and create a JSON file containing all previous blog posts any time I update the blog with new content.
This JSON file can be found at [https://devblackops.io/feed.json](https://devblackops.io/feed.json), and you can see how I generate it [here](https://github.com/devblackops/devblackops.github.io/blob/master/jsonfeed.html).

A snippet of what this JSON looks like is below:

```json
{
    "title": "DevBlackOps",
    "description": "Thoughts about DevOps and automation from a Windows guy",
    "url": "https://devblackops.io/",
    "date": "Fri, 07 Sep 2018 04:02:33 +0000",
    "posts": [
        {
            "title": "The PowerShell Conference Book",
            "url": "https://devblackops.io/the-powershell-conference-book/",
            "date": "Mon, 09 Jul 2018 00:00:00 +0000",
            "tags": [
                "PowerShell"
            ],
            "categories": [
                "PowerShell"
            ]
        },
        {
            "title": "The Operation Validation Framework: Test your infrastructure using Pester",
            "url": "https://devblackops.io/the-operation-validation-framework-test-your-infrastructure-using-pester/",
            "date": "Mon, 25 Jun 2018 00:00:00 +0000",
            "tags": [
                "PowerShell",
                "Infrastructure",
                "Testing",
                "Pester",
                "OVF",
                "Operation Validation"
            ],
            "categories": [
                "PowerShell"
            ]
        }
    ]
}
```

## The Azure Function

This PowerShell-based Azure Function consumes the JSON feed from my blog, select a random post, then tweet it out.
Hashtags are also created based on any tags defined in the blog post.
I’m also borrowing some code from [MeshkDevs](https://github.com/MeshkDevs) in the [InvokeTwitterAPIs](https://github.com/MeshkDevs/InvokeTwitterAPIs) repository to send tweets using PowerShell.

The Azure Function runs on a schedule and consumes the JSON feed from my blog.
When the Function is triggered based on the schedule, a JSON-based tracker file hosted in Azure storage is passed as input.
An array of available posts to tweet is created by taking the posts from the JSON feed and removing any previously tweeted posts contained in the tracker file.
A random post is selected from whatever posts are left.
This post is then tweeted out and added to the tracker file so it won’t be sent again until all available posts of been tweeted out.

The relevant bits of the Function are below.
To see the whole function including how to create short links using Bitly and send tweets to Twitter, check out the [whole file](https://github.com/devblackops/blog-archive-tweeter-example/blob/master/sendblogtweet/run.ps1) in the GitHub [repo](https://github.com/devblackops/blog-archive-tweeter-example).

#### run.ps1

```powershell
# I don't want these URLs tweeted out as they're not very relevant
$excludedPosts = @()

# Load tracker file
$tracker = Get-Content $inBlob | ConvertFrom-Json
Write-Output "Last tweeted: $($tracker.lastTweetedTime)"

# Get random blog post from feed
$blog           = Invoke-RestMethod -Uri $env:BLOG_FEED_URL
$candidatePosts = $blog.posts.Where({$_.url -notin $excludedPosts})

# Get a post from the list of available posts that we haven't already tweeted
$tweetedUrls    = $tracker.tweetedPosts | Select-Object -ExpandProperty url
$availablePosts = $candidatePosts.Where({$_.url -notin $tweetedUrls})
$post           = $availablePosts | Get-Random
$availablePosts = $availablePosts.Where({$_.url -ne $post.Url})

if (-not $post) {
    # We've exhausted all available posts so reset
    # the tracker and get a new post from the candidates
    $post                 = $candidatePosts | Get-Random
    $tracker.tweetedPosts = @()
    $availablePosts       = $candidatePosts.Where({$_.url -ne $post.Url})
}

$tracker.candidatePostsCount = $candidatePosts.Count
$tracker.availablePostsCount = $availablePosts.Count

if ($post) {
    $postJson = $post | ConvertTo-Json
    Write-Output "Retrieved post:`n$postJson"

    # Create hashtags
    $hashtags = ''
    $post.tags | Foreach-Object {
        $tag = $_ -replace ' ', ''
        $hashtags += (' #' + $tag)
    }
    $hashtags = $hashtags.Trim()

    # Create tweet text
    $title     = $post.title
    $link      = Get-ShortUrl -Url $post.url -OAuthToken $env:BITLY_OAUTH_TOKEN
    $tweetText = "From the blog archive: $Title`n`n$link`n`n$hashtags"
    Write-Output "Sending tweet:`n$tweetText"
    $oAuth = @{
        ApiKey            = $env:TWITTER_CONSUMER_KEY
        ApiSecret         = $env:TWITTER_CONSUMER_SECRET
        AccessToken       = $env:TWITTER_ACCESS_TOKEN
        AccessTokenSecret = $env:TWITTER_ACCESS_SECRET
    }
    $tweetParams = @{
        ResourceURL   = 'statuses/update.json'
        RestVerb      = 'POST'
        Parameters    = @{
            status = $tweetText
        }
        OAuthSettings = $oAuth
    }
    $tweet     = Invoke-TwitterRestMethod @tweetParams
    $tweetJson = $tweet | ConvertTo-Json
    Write-Output "Tweet sent:`n$tweetJson"

    # Add tweeted post to tracker
    $now = (Get-Date).ToUniversalTime().ToString('u')
    $tracker.lastTweetedTime = $now
    $tweetedPost = @{
        url          = $post.Url
        lastTweeted  = $now
    }
    $tracker.lastTweetedPost     = $tweetedPost
    $tracker.tweetedPosts        += $tweetedPost
    $tracker.tweetedPostCount    = $tracker.tweetedPosts.Count
    $tracker.candidatePostsCount = $candidatePosts.Count
    $tracker.availablePostsCount = $availablePosts.Count
    $trackerJson = $tracker | ConvertTo-Json
    Write-Output "Saving tracker to blob:`n$trackerJson"
    $trackerJson | Out-File -Encoding UTF8 -FilePath $outBlob
}
```

The Function bindings are defined in [function.json](https://github.com/devblackops/blog-archive-tweeter-example/blob/master/sendblogtweet/function.json).
You can see that I've set a timer-based trigger to fire this function.
You can check out how [cron expressions](https://docs.microsoft.com/en-us/azure/azure-functions/functions-bindings-timer#cron-expressions) work in the Microsoft documentation.
In this example, the function is triggered every `Monday, Wednesday, and Friday at 6:24am UTC`.

I'm also defining an input binding to the tracker file contained in Azure storage.
This same file is also defined as an output binding as the Function both reads and writes to it.

#### function.json

```json
{
    "bindings": [
        {
            "type": "timerTrigger",
            "name": "myTimer",
            "schedule": "0 24 6 * * 1,3,5",
            "direction": "in"
        },
        {
            "type": "blob",
            "name": "inBlob",
            "path": "sendblogtwitter/posts.json",
            "connection": "blogarchivetweeter_STORAGE",
            "direction": "in"
        },
        {
            "type": "blob",
            "name": "outBlob",
            "path": "sendblogtwitter/posts.json",
            "connection": "blogarchivetweeter_STORAGE",
            "direction": "out"
        }
    ],
    "disabled": false
}
```

## Deploying the Function

If you want to follow along at home, it is best if you clone the [GitHub repo](https://github.com/devblackops/blog-archive-tweeter-example) and `cd` into it to run the deployment commands

```powershell
git clone https://github.com/devblackops/blog-archive-tweeter-example
cd ./blog-archive-tweeter-example
```

To start, we're going to define all our variables up front.
Fill in these with your relevant information.
For generating Twitter tokens used by this process, you can start [here](https://developer.twitter.com/en/docs/basics/authentication/guides/access-tokens.html).
To generate a Bitly OAuth token, follow the directions [here](https://dev.bitly.com/get_started.html).

```powershell
# Settings
$subscription         = '<YOUR-AZURE-SUBSCRIPTION>'
$resourceGroup        = '<RESOURCE-GROUP-NAME>'
$region               = '<AZURE-REGION>'
$storageAcct          = '<STORAGE-ACCOUNT-NAME>'
$storageContainerName = '<STORAGE-CONTAINER-NAME>'
$functionApp          = '<FUNCTION-APP-NAME>'
$blogFeedUrl          = '<YOUR-FEED-URL>'
$twitterAccessSecret  = '<TWITTER-ACCESS-SECRET>'
$twitterAccessToken   = '<TWITTER-ACCESS-TOKEN>'
$twitterConsumerKey   = '<TWITTER-CONSUMER-KEY>'
$twitterConsumeSecret = '<TWITTER-CONSUMER-SECRET>'
$bitlyOauthToken      = '<BITLY-OAUTH-TOKEN>'
```

Now we can log into Azure using [AZ CLI](https://docs.microsoft.com/en-us/cli/azure/?view=azure-cli-latest) and create a resource group to hold our Function and storage account.

```powershell
az login
az account set --subscription $subscription
az group create --name $resourceGroup --location $region
```

Create a new storage account and retrieve the connection string to it.

```powershell
az storage account create --resource-group $resourceGroup --name $storageAcct --location $region --sku Standard_LRS
$storageConnStr = az storage account show-connection-string --resource-group $resourceGroup --name $storageAcct --output tsv
```

Create a storage container and upload the empty tracker file. This file can be found in the GitHub repo [here](https://github.com/devblackops/blog-archive-tweeter-example/blob/master/posts.json).

```powershell
az storage container create --account-name $storageAcct --name $storageContainerName
az storage blob upload --account-name $storageAcct --container-name $storageContainerName --name posts.json --file ./posts.json
```

Now create the Function App and set the application settings.

```powershell
az functionapp create --resource-group $resourceGroup --name $functionApp --storage-account $storageAcct --consumption-plan-location $region
az functionapp config appsettings set --resource-group $resourceGroup --name $functionApp --settings "FUNCTIONS_EXTENSION_VERSION = ~1"
az functionapp config appsettings set --resource-group $resourceGroup --name $functionApp --settings "BLOG_FEED_URL = $blogFeedUrl"
az functionapp config appsettings set --resource-group $resourceGroup --name $functionApp --settings "TWITTER_ACCESS_SECRET = $twitterAccessSecret"
az functionapp config appsettings set --resource-group $resourceGroup --name $functionApp --settings "TWITTER_ACCESS_TOKEN = $twitterAccessToken"
az functionapp config appsettings set --resource-group $resourceGroup --name $functionApp --settings "TWITTER_CONSUMER_KEY = $twitterConsumerKey"
az functionapp config appsettings set --resource-group $resourceGroup --name $functionApp --settings "TWITTER_CONSUMER_SECRET = $twitterConsumeSecret"
az functionapp config appsettings set --resource-group $resourceGroup --name $functionApp --settings "BITLY_OAUTH_TOKEN = $bitlyOauthToken"
az functionapp config appsettings set --resource-group $resourceGroup --name $functionApp --settings "blogarchivetweeter_STORAGE = $storageConnStr"
```

Now we have to deploy the actual function.
To do this, we'll zip up the entire GitHub repository and deploy it into the Function App.

```powershell
Compress-Archive -Path * -DestinationPath function.zip
az functionapp deployment source config-zip --resource-group $resourceGroup --name $functionApp --src ./function.zip
```

## Summary
That's it.
At this point, you should have both a Function App and storage account deployed in the resource group with the function triggering based on a timer.
Make sure to replace all the relevant settings for your Azure environment, Twitter/Bitly credentials, and blog feed URL.

Now you have a serverless blog post tweeter happily sending out your past blog posts to your followers.

Happy tweeting!

Cheers.
