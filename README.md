# Iqeo::Configuration

A DSL for writing configuration files.

## Installation

It's a gem...

```
$ gem install iqeo-conf
```

## Usage

Require it...

```ruby
require 'iqeo/configuration'
```

### Create a configuration

Set values...

#### Directly on a configuration object

```ruby
conf = Iqeo::Configuration.new

# add some settings

conf.alpha 42
conf.bravo "foobar"
conf.charlie { :a => 1, :b => 2, :c => 3 }
conf.delta [ 1, 2, 3 ]
```

#### Configuration DSL block yield style

```ruby
conf = Iqeo::Configuration.new do |c|

  c.alpha 42
  c.bravo "foobar"
  c.charlie { :a => 1, :b => 2, :c => 3 }
  c.delta [ 1, 2, 3 ]

end
```

#### Configuration DSL instance_eval style

```ruby
conf = Iqeo::Configuration.new do

  alpha 42
  bravo "foobar"
  charlie { :a => 1, :b => 2, :c => 3 }
  delta [ 1, 2, 3 ]

end
```

### Reading a configuration

Retrieve settings...

```ruby
conf.alpha      =>  42
conf.bravo      =>  "foobar"
conf.charlie    =>  { :a => 1, :b => 2, :c => 3 }
conf.delta      =>  [ 1, 2, 3 ]
```

## Other features

This README may not be complete, see rspec tests for all working features.

## Done

Need docs...

* Hash operators [] & []=
* Nested configurations
* Nested configurations inherit settings
* Nested configurations override inherited settings
* Load configurations from a string or file at creation
* Iterate over items hash - by delegation to hash
* Indifferent hash access - using ActiveSupport/HashWithIndifferentAccess

## Todo

Need time (have motivation)...

* Configuration file load path
* Use an existing configuration for defaults
* Clean DSL syntax for creating a nested configuration - just a block ?
* Load configurations from a string or file after creation / in DSL block
* Option to get hash directly to prevent polluting namespace with delegated hash methods
* Blank slate for DSL ? - optional ?
* Consider issues around deferred interpolation / procs / lambdas etc...
* Load other formats into configuration - YAML, CSV, ...anything Enumerable should be easy enough.

## License

Licensed under GPL Version 3 license
See LICENSE file

