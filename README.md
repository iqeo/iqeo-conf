# Iqeo::Configuration

A DSL for writing configuration files.

## Installation

It's a gem...

```
$ gem install iqeo-conf
```

## Usage

### Defining a configuration

```ruby
require 'iqeo/configuration'
```

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

### Configuration DSL instance_eval style

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

This README may not be complete, see rspec tests for all features.

## Todo

* Access settings by hash
* Create settings by hash ?
* Indifferent hash access
* Nested configurations
* Inherited settings for nested configurations
* Load configurations from a string & file
* Load other formats ? - No need... DSL is just ruby, just do it natively.
* Blank slate for DSL ?

## License

Licensed under GPL Version 3 license
See LICENSE file

