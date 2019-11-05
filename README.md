# [Snitch](https://192.168.1.205)

**Metadata**
> Ruby 2.6.0
> Rails 5.2.2.1
> PostgreSQL
> SemanticUI
> NGINX
> Phusion passenger

**Contents**
1. How it works from a user's point of view ([user manual](#user-manual))
   1. [Inventory](#Inventory)
   2. [Cyberadapt traffic](#Cyberadapt)
   3. [Whitelists](#whitelists)
      1. [Cyberadapt whitelist](#cyberadapt-whitelist)
      2. [FS-ISAC whitelist](#fs-isac-whitelist)
   4. [FS-ISAC alerts](#fs-isac-alerts)
   5. [Uploading](#uploading)
      1. [Carbon Black Log](#carbon-black-log)
   6. [Blacklist](#blacklist)
2. [Developer information](#developer-information) (only the important
   stuff)
   1. [Getting cyberadapt data](#getting-cyberadapt-data)

# User manual

## Inventory

Navigate to [/machines](192.168.1.78/machines) to see our inventory.

The data on this page includes plenty of information:

* ID
* Department
* Host
* Last known IP
  ** This IP is derived from Carbon black defense; its accuracy decreases over time
* User
* Last day CarbonBlack saw this
  ** Use this data for the last IP field to determine how accurate the IP is
* Creation date
* Last update timestamp

You can also perform these actions:

* Modify machine
  * You can add a new machine (button toward the top)
  * Edit a machine by clicking on the IDs
  * Delete the machine by clicking the trash can
* You have a ton of options to filter data with using GET params
* You can download the whole list as a CSV

## Cyberadapt

Navigate to [/uri_entries](https://192.168.1.78/uri\_entries) to see
our data from Cyberadapt's network logs.

This data is pulled from Cyberadapt's repository of our internet traffic. In the log it has IP, URI, and how many times visited, and we combine it with other information to make it more insightful.

* ID
* IP
* User (if known)
* Host (if known)
* URI
* Hits
* When Cyberadapt recorded the data
* Creation date (when it was inserted into the database, not when the info was recorded)
* Last updated date

You can perform these actions:

* Pull more information from the Cyberadapt endpoint
* Download all records as a CSV (very large operation, takes awhile)

## Whitelists

### Cyberadapt whitelist

The Cyberadapt logs are typically massive and we don't want to log all
the traffic to conserve space and aid us better in
response by filtering away the extra garbage. The Cyberadapt whitelist gets rid of some of the data that
we don't care about/is doubled in Carbon black response.

Create a whitelist entry, which is just a regular expression in Ruby, and it
will not save the entry if the URI for the entry matches the regular
expression. Example:

```ruby 
    # Any local IP address is not logged
    /192\.168\./(\d+)\.(\d+)/
```

Before you create or edit one, you should test it first with
[rubular](https://rubular.com/) or with IRB.

You can edit, delete, or create new whitelist rules. When you add a
whitelist rule, it will run it against everything currently in the
database and remove matching entries.

### FS-ISAC whitelist

The FS-ISAC threat feed is heavily populated with emails that will
not affect our enterprise. Instead of sifting through manually of what
does/doesn't affect us, the whitelist allows us to immediately
classify certain emails as not relevant to the enterprise.

When we get an email with the title "IBM blah blah blah" we already
know it won't affect us, so we use a ruby regex that automatically
classifies the email as "does not apply". Here's an abstraction of
what happens basically:

```ruby
    whitelist = /IBM/
    whitelist.match? email.title
```

And if the whitelist matches the email title, it marks the email as
does not apply.

You can edit, create, and delete whitelist entries.

## FS-ISAC alerts

The FS-ISAC threat feed is demuxed into a JSON object which is piped
into our database so we can use the information for patching and other
cybersec purposes. The emails are retrieved from
[reporting@flexibleplan.com](mailto:reporting@flexibleplan.com)
through a forwarding rule.

You can see a subset of information by viewing them in the table, but
click on their IDs to see all their information:

* Name of the alert (this is what we use to determine if the
  [whitelist](#fs-isac-whitelist) should take effect)
* Whether or not it applies to us
* The severity of the alert, given to us by FS-ISAC
* Description
* Sources
* Corrective action
* Affected Products
* Timestamp of when it was released from FS-ISAC's end
* Comment (something that the analyst should write up)

You can edit part of the alert but not everything, as a lot of it is
directly from FS-ISAC, and should be readonly. You can mark an alert
as resolved and mark it as "doesn't apply". 

Additional actions include the option to
download as a CSV and the more important "pull new alerts" button,
which makes an API request to get new alert emails from
[reporting@flexibleplan.com](mailto:reporting@flexibleplan.com).

## Uploading

Uploading logs is actually one of the features that, if more
development efforts can be pushed, should be completely phased out. At
the time of development, I wasn't aware of the APIs that we had access
to so we did everything manually and wasted a lot of man-hours and the
solution was still worse.

Avoid these features if you can, they are **suboptimal**

### Carbon black log

\*Please read [this](#uploading) first\*

Quite simply, this log is how we determine a machine's IP address for
[/machines](https://192.168.1.78/machines/). You can get a Carbon
Black log by going to Carbon Black defense -> Logging in -> Endpoints
-> CSV export. This log is what gets dropped in, and we use that to
create our inventory and our DHCP log.

### Whitelist log

THIS FEATURE IS DEPRECATED, DON'T USE IT

## Blacklist

THIS FEATURE IS NOT COMPLETED, DON'T USE IT

# Developer information

Unfortunately, when creating Snitch we were not concerned with a
proper development cycle so there's not much documentation on what has
to happen or how I accomplished what I did. But this is my best effort
to explain everything so at the very least you can reinvent the wheel
(better than before) because there were a lot of paths taken that
shouldn't have been, but I wasn't aware of them at the time.

**General notes:**
* I removed the `/lib` folder and put it in `/app`. Most Rails devs
  see that as better.
* I have pretty heavily tested the core library for the project, but I
  didn't really care much about controller/view testing. See above for
  why
* The way that we got the Cyberadapt logs is **not optimal**, they
  have an API that we should have used instead of running it through
  SFTP and creating a log parser. This will **cut the code base down
  and increase reliability** if you can change it
* The way we determine the IP address of machines is **very not
  optimal**. Carbon black has an API that would allow us to possibly
  get this information real time.

1. [Abstract view of the most complicated topics](#abstract-view)
   1. [Getting cyberadapt data](#getting-cyberadapt-data)
   2. [Getting mail](#getting-mail)
2. [Deployment](#deployment)
3. [Upkeep](#upkeep)

## Abstract view

### Getting cyberadapt data

Under the hood, the Cyberadapt model is actually called
`UriEntries`. When you call `CyberAdaptSftpClient#get_missing`, you:

1. Start SFTP with [remote.cyberadapt.com](remote.cyberadapt.com)
2. Look at all the network logs, find which ones we don't have already
   based on the `PaperTrail` table
3. Download these logs, putting them in an array as a `String` if I
   remember correctly; this doesn't really matter though, the next
   step takes care of it anyways

Once you have this array, each element should be passed into
`CyberAdaptLog#new`, which

1. Demuxes the CSV
2. Checks it against the whitelist
3. Insert into `UriEntries`

### Getting mail

To get FS-ISAC alerts, we have a rather complicated process but it
works really well.

1. FS-ISAC sends an email containing all the threat feed
   information. These emails are sent to whoever is a member on their
   service.
2. We forward the email we get to a service mailbox,
   [reporting@flexibleplan.com](mailto:reporting@flexibleplan.com). All
   the emails that are ever sent to us through FS-ISAC are therefore
   in the service mailbox.
3. We do an API request using a gem called `Viewpoint` that
   authenticates us to the Exchange server
4. We get every email using `FsIsacMailClient`
5. We parse every email using `FsIsacMailParser`, turning it into a
   ruby hash
6. We insert each one into the database

There are some important details to consider:

* The credentials for
  [reporting@flexibleplan.com](mailto:reporting@flexibleplan.com) are
  stored on the production server in `secrets.yml` because that's the
  only way we can authenticate. Details on this later.
* Since
  [reporting@flexibleplan.com](mailto:reporting@flexibleplan.com) is
  under microsoft, the password for this account will need to be reset
  every 90 days per GPO. It might be possible to turn this off but I'm
  not sure.

## Deployment



## Upkeep
