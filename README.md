#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with burp](#setup)
    * [What burp affects](#what-burp-affects)
    * [Beginning with burp](#beginning-with-burp)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)
7. [Contributors](#contributors)

## Overview

This module installs and configures the [BURP](http://burp.grke.org/) backup software (client and server mode).
BURP stands for `BackUp and Restore Program`.

[![Build Status](https://travis-ci.org/vshn/puppet-burp.svg)](https://travis-ci.org/vshn/puppet-burp)
[![vshn-burp](https://img.shields.io/puppetforge/v/vshn/burp.svg)](https://forge.puppetlabs.com/vshn/burp)

## Module Description

BURP provides one binary for client and server mode. The behaviour depends on the configuration file,
passed to the application with the `-c` parameter.
This module provides two main functions:

* configuring the BURP backup server
* creating one or more BURP backup client configurations

The default parameters are applicable for BURP version 1.x, but the flexible nature of this module
also allows to use the upcomming [BURP version 2](http://burp.grke.org/burp2.html).

In opposite to the original BURP packaging, this Puppet module configures BURP to only have configuration
files in `/etc/burp` and no dynamic data. All dynamic data like SSL certificates (CA) and the backup
data is by default configured to be located under `/var/lib/burp` (server) and `/var/lib/burp-<clientname>`.

There can by many client configurations, f.e. to backup to different backup servers
with different parameters. Just instantiate the `::burp::client` defined type. The default
client is name 'burp' because this is the name of the default configuration file and makes
it easier to call the application (so you don't need to add `-c` to every call).

## Setup

### What burp affects

* Package `burp`
* Configuration files under `/etc/burp/`
* BURP server: directory `/var/lib/burp`
* BURP client: directory `/var/lib/burp-${name}`
* System service `burp` if configuring the server
* Cronjob if configuring a client
* Exported resources for creating clientconfigs on the backup server
* Delivery of some default scripts to `/usr/local/bin`:
  * `burp_timer_script`
  * `burp_summary_script`
  * `burp_notify_script`
  * `burp_ssl_extra_checks_script`

### Beginning with burp

Instantiating the main class `burp` does only install the package and will do some preparations, but
nothing more. You need to chose which mode you want to configure:

**BURP server mode**

```
class { ::burp::server: }
```

**BURP client mode**

```
class { ::burp:
  clients => {
    burp = {}
  }
}
```

*or*

```
::burp::client { 'burp': }
```

## Usage

To find the default values and parameter documentation, have a look at the `.pp` files. Everything is documented there.

## Reference

This sections describes some specialities

### burp::extraconfig

This defined type allows to add some extra configuration to the client from "outside".
Configuration directives written to this extra configuration file is included in the main client configuration file.
It is located by default under `/etc/burp/<clientname>-extra.conf`.

Example:
```
::burp::extraconfig { 'do_this':
  client        => 'burp',
  configuration => { 'include' => [ '/opt/', '/tmp/' ] },
}
```

## Limitations

The module has been developed under Ubuntu. But it should also work on Debian, RedHat, CentOS and probably more Linux OS.

## Development

1. Fork it (https://github.com/vshn/puppet-burp/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

Make sure your PR passes the Rspec tests.

## Contributors

Have a look at [Github contributors](https://github.com/vshn/puppet-burp/graphs/contributors) to see a list of all the awesome contributors to this Puppet module. <3

