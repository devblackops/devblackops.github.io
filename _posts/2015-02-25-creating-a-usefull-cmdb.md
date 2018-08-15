---
title:  "Creating a useful CMDB"
date:   2015-02-25
categories: [CMDB]
featured-image: posts/creating-a-usefull-cmdb/road.jpg
comments: true
hide_from_feed: true
tags: [CMDB]
---

This is the first post in what I intend to be a series of posts detailing the creation of a useful CMDB for your IT organization and how that CMDB can be used to assist in DevOps processes. At the end of the series, I hope to show how the CMDB can help drive automation in your IT environment by being a central hub for pushing/pulling information.

First off, it is important to define what a CMDB is and why you should think about implementing one.

### What is a CMDB?

A CMDB can mean many things to different people. Let's start with the definition according to Wikipedia.

A configuration management database (CMDB) is a repository that acts as a data warehouse for information technology (IT) organizations. Its contents are intended to hold a collection of IT assets that are commonly referred to as configuration items (CI), as well as descriptive relationships between such assets. When populated, the repository becomes a means of understanding how critical assets such as information systems are composed, what their upstream sources or dependencies are, and what their downstream targets are.

### What is a CI?

A CI is a unique "thing" that you want to track and will be an instance of any number of defined CI types. You may have CI types for a physical server, virtual machine, switch, router, rack, database, firewall, UPS, etc. The CI types will share a handful of common attributes like ID, name, description and each type will have unique attributes relating just to it. In the case of a physical server this may be manufacturer, model, serial number, size in rack units. In the case of a VMware VM, it may be vCPUs, vRAM, type and number of VMDKs, etc.

### What is a CI relationship?

A CI relationship defines how two or more CIs are related to each other. Documenting the relationships between CIs can assist in answering to the following questions:

* What web server CIs are connected to a database on dbserver03?
* What are the upstream and downstring CIs connected to appserver06?
* How many physical servers are connected to switch10?
* What VMs are running on this VM host?

These relationships are critical in understanding what your IT landscape looks like and how everything fits together. They are also extremely valuable when troubleshooting a problem.

### Benefits of a CMDB

The benefits of a fully populated and accurate CMDB are enormous. First off, it is a central place to hold all the "hard" data about your IT resources:

* Asset Type
* Serial Number
* Asset Tag
* Manufacturer
* Model
* Rack units
* etc...

But the CMDB is also a great place to hold all of your "soft" data as well and often, this is the most valuable:

* Name
* Service (what service does this CI provide and to who?)
* IP address
* FQDN
* Location
* Contact person (primary / alternate)
* Status
* Environment (Dev/Test, QA, Prod, etc)
* Zone (DMZ, internal, private, hybrid)
* CIs related to this one (servers connected to switch SW01A)
* Maintenance windows

Once at least some of this data is present in the CMDB, you can start analyzing your environment for useful information.

* Ratio of Linux to Windows servers
* Number of virtual machines in Chicago
* Distribution of virtual machine resources (vCPU, vRAM, vStorage) globally
* CI count trend over time.

In later posts I will discuss ideas for:

* CMDB architecture,
* Useful CI types
* CI relationships
* CI discovery
* CI configuration
* Reporting / dashboards
* Integrations with VMware/Puppet/Chef/DSC.

Cheers,
Brandon
