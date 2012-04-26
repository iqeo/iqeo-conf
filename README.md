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

* Hash operators [] & []= - done!
* Nested configurations - done!
* Nested configurations inherit settings - done!
* Nested configurations override inherited settings - done!
* Load configurations from a string or file at creation - done!

## Todo

Need time (have motivation)...

* Indifferent hash access, symbol, strings, case sensitivity optional ?
* Iterate over items hash - access to hash / mixin enumerable / delegation to hash ?
* Load configurations from a string or file after creation / in DSL
* Configuration file load path - array of Dir.glob like file specs ?
* Load other formats ? - No need... DSL is just ruby, just do it natively ?
* Blank slate for DSL ? - optional ?
* Use an existing configuration for defaults
* Global configuration - watch for collisions ?
* Consider issues around deferred interpolation / procs / lambdas etc...

## License

Licensed under GPL Version 3 license
See LICENSE file

