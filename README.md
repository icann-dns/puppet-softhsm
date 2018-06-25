[![Build Status](https://travis-ci.org/icann-dns/puppet-softhsm.svg?branch=master)](https://travis-ci.org/icann-dns/puppet-softhsm)
[![Puppet Forge](https://img.shields.io/puppetforge/v/icann/softhsm.svg?maxAge=2592000)](https://forge.puppet.com/icann/softhsm)
[![Puppet Forge Downloads](https://img.shields.io/puppetforge/dt/icann/softhsm.svg?maxAge=2592000)](https://forge.puppet.com/icann/softhsm)

# SoftHSM

#### Table of Contents

1. [Overview](#overview)
3. [Setup - The basics of getting started with dns](#setup)
    * [Setup requirements](#setup-requirements)
    * [Beginning with SoftHSM](#beginning-with-softhsm)
    * [Tokens](#tokens)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

Install SoftHSM and manage security tokens

## Module Description


## Setup

### What SoftHSM affects

* installs and manages softhsm2

### Setup Requirements 

* puppetlabs-stdlib 4.17.0
* icann-tea 0.2.12

### Beginning with SoftHSM

install either package with no token

```puppet 
class { '::softhsm': }
```

### Tokens

Add a new token

```puppet
softhsm::token { 'test'
  pin    => '1111',
  so_pin => '1111',
}
```

you can also pass tokens directly to the class

```puppet
class {'::softhsm':
  tokens => {
    'test' => {
      'pin'    => '1111',
      'so_pin' => '1111',
    },
  },
}
```
Or via hiera

```yaml
softhsm::tokens:
  test:
    pin: 1111
    so_pin: 1111
```

## Reference


- [**Public Classes**](#public-classes)
    - [`dns`](#class-softhsm)
- [**Public Types**](#public-types)
    - [`softhsm::token`](#type-softhsmtoken)

### Classes

### Public Classes

#### Class: `softhsm`
  
##### Parameters

* `package` (String, Default: 'softhsm2'): The SoftHSM package to install
* `conf_file` (Stdlib::Absolutepath, Default: '/etc/softhsm/softhsm2.conf'): the location of the lof file
* `tokendir` (Stdlib::Absolutepath, Default: '/var/lib/softhsm/tokens/'): the location of the tokens directory
* `objectstore_backend` (Enum['file','db'], Default: 'file'): how to stor objects
* `log_level` (Tea::Syslog_level, Default: 'info'): Syslog level to use
* `tokens` (Hash[String, Softhsm::Token], Default: {}): tokens to configure 

### Public Types

#### Type `softhsm::token`

##### Parameters

* `pin` (Pattern[/\d{4,255}/]): user pin to configure
* `so_pin` (Pattern[/\d{4,255}/]): security office pin to configure


## Limitations

This module has been tested on:

* Ubuntu 12.04, 14.04
* FreeBSD 10

## Development

Pull requests welcome but please also update documentation and tests.

## Contributors
* [b4ldr](https://github.com/b4ldr/)
* [btoonk](https://github.com/btoonk)
