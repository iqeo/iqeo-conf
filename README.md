# Iqeo::Configuration

[![Gem Version](https://badge.fury.io/rb/iqeo-conf.png)](http://badge.fury.io/rb/iqeo-conf)
[![Build Status](https://travis-ci.org/iqeo/iqeo-conf.png?branch=master)](https://travis-ci.org/iqeo/iqeo-conf)

A DSL representing configuration files.

## Installation

It`s a gem...

    $ gem install iqeo-conf

## Usage

Require 'iqeo/configuration' and optionally include Iqeo namespace:

```ruby
require 'iqeo/configuration'
include Iqeo
```

### Create configuration

There are three ways to create configurations; explicit, block DSL, eval DSL.

#### Explicit

Call Configuration#new without a block.
Explicitly call methods on instance to configure instance.

```ruby
conf = Configuration.new
conf.alpha   1
conf.bravo   2.0
conf.charlie :three
conf.delta   "four"
```

#### Block DSL

Call Configuration#new with a block that expects a variable, a new instance will be yielded.
Within block, call methods on yielded instance to configure.

```ruby
conf = Configuration.new do |c|
  c.alpha   1
  c.bravo   2.0
  c.charlie :three
  c.delta   "four"
end
```

#### Eval DSL

Call Configuration#new with a block that does not expect a variable, contents of the block are eval`d in the context of the new instance.
Call methods with implied self to configure instance.

```ruby
conf = Configuration.new do
  alpha   1
  bravo   2.0
  charlie :three
  delta   "four"
end
```

### Read configuration

All examples above result in the same configuration.
Configuration settings can be retrieved directly or indirectly.

#### Directly

##### Named method

```ruby
conf.alpha        # => 1
conf.bravo        # => 2.0
conf.charlie      # => :three
conf.delta        # => "four"
```

##### [ 'string' ]

```ruby
conf['alpha']     # => 1
conf['bravo']     # => 2.0
conf['charlie']   # => :three
conf['delta']     # => "four"
```

##### [ :symbol ]

```ruby
conf[:alpha]      # => 1
conf[:bravo]      # => 2.0
conf[:charlie]    # => :three
conf[:delta]      # => "four"
```

#### Indirectly

The underlying storage is an indifferent hash, so the usual Hash and Enumerable methods work.

##### Hash & Enumerable methods

```ruby
conf.size                           # => 4
conf.keys                           # => [ 'alpha', 'bravo', 'charlie', 'delta' ]
conf.collect { |key,value| value }  # => [ 1, 2.0, :three, 'four' ]
```

## Features

* settings by named methods
* settings by '[]' & '[]='
* settings & locals with '='
* referencing existing settings
* nested configurations
* inheritance & override
* read from string, at creation, or after - merged & nested
* load from filename, at creation, or after - merged & nested
* defaults
* merge configurations recursively
* blank slate for DSL
* wildcard * for chained usage: a.b.*.d

## Application

* Dynamic settings by '[]' & '[]=' & 'self'
* Multiple configuration files
* Hierarchial configuration files
* Validation: if a.b.*.d == true

## License

Copyright Gerard Fowley (gerard.fowley@iqeo.net).

Licensed under GPL Version 3 license.
See LICENSE file.
