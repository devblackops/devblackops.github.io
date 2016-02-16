---
title:  "Introducing ServerDB - The CMDB You Actually Want to Use"
date:   2015-03-24
featured-image: posts/introducing-serverdb-the-cmdb-you-actually-want-to-use/serverdb-dashboard.png
excerpt: "I'd like to talk about a project I'm been working on called ServerDB. This has been a pet project of mine for a number of years now and recently I've started developing a new version from the ground up intended for a wider audience."
comments: true
categories: [CMDB]
tags: [CMDB, DSC, VMware]
---

I'd like to talk about a project I'm been working on called ServerDB. This has been a pet project of mine for a number of years now and recently I've started developing a new version from the ground up intended for a wider audience. Below you will find an overview of what ServerDB is, the intended feature list, the current state of development, some screenshots intended to give you a sense of what it can do, and log in details to try the admittedly very alpha version for yourself. Enjoy.

If you have any questions about ServerDB, ask away in the comments below or you can contact me on Twitter [@devblackops](https://twitter.com/devblackops).

### Alpha Demo details:

- [http://demo.serverdb.io](http://demo.serverdb.io)
- username: demo
- password: serverdb

### What is ServerDB?

ServerDB is a web based CMDB intended for IT administrators to get a handle on managing the systems in their environment.

It is intended to be straightforward for the average IT admin to use and pull information out of.
It it designed for highly virtualized environments but that is not a requirement.
It is meant to hold information useful for IT admins about the state of their servers and related systems.
It is meant to be populated via automatic discovery scripts against the REST API. Very little information should have to be entered manually.

### What ServerDB is Not

It is **NOT** meant to be a ITIL compliant all encompassing CMDB populated with every single nugget of information about your entire IT landscape down to the DIMMs in your servers in Singapore. If you want that, the big players out there would love to hear from you.

### Main Features

* **Dashboard** - Exposes vitals about your environment.
* **CI Explorer**
  * The main interface in the application.
  * View details about individual CI (Configuration Items) in the database.
* **CI Groups** - Create groups to organize your CIs and apply permissions.
* **Desired State**
  * Integration with Microsoft's DSC technology.
  * Manage DSC resources and apply them to individual CIs or groups of CIs.
* **Relationship Builder** - Define relationships between CIs.
* **Query** - Query and export information about your CIs.
* **Services** - Organize CIs into the various IT and business services they provide (e.g. Mail Servers, ERP Application, Web Portal, etc).
* **Reports** - Simple reporting engine.
* **Virtualization**
  * Overview of your virtualization environment.
  * Show VM count and resource trends.
  * Calculate VM costs for showback.
  * Compare private cloud costs to public cloud.
* **Administration**
  * Define base data used throughout the application.
  * Manage users and access rights.
  * System Settings.

### Current State

ServerDB is in very alpha form right now and the list of incomplete or missing features far outnumbers the complete ones and there are a number of areas that are still just mock ups.  Still, I hope what you see will give you a decent idea of the application and hopefully some of you will find the project interesting.

Feel free to log into the demo site below and explore. Remember, this is in very alpha form right now and contains a number of bugs.

### Alpha Demo details:

* [http://demo.serverdb.io](http://demo.serverdb.io)
* username: demo
* password: serverdb

Again, if you have any questions about ServerDB, ask away in the comments below or you can contact me on Twitter [@devblackops](https://twitter.com/devblackops).

Cheers.
