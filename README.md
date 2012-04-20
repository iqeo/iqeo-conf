# Iqeo::Configuration

A DSL for writing configuration files.

## Installation

Add this line to your application's Gemfile:

```
gem 'iqeo-conf'
```

And then execute:

```
$ bundle
```

Or install it yourself as:

```
$ gem install iqeo-conf
```

## Usage

### Defining a configuration

Set values...

#### Defining a Configuration object directly

```ruby
conf = Iqeo::Configuration.new

# add some settings

conf.alpha 42
conf.bravo "foobar"
conf.charlie { :a => 1, :b => 2, :c => 3 }
conf.delta [ 1, 2, 3 ]
```

#### Configuration DSL - builder style

```ruby
conf = Iqeo::Configuration do |c|

  conf.alpha 42
  conf.bravo "foobar"
  conf.charlie { :a => 1, :b => 2, :c => 3 }
  conf.delta [ 1, 2, 3 ]

end
```

### Configuration DSL - freestyle

```ruby
conf = Iqeo::Configuration do

  alpha 42
  bravo "foobar"
  charlie { :a => 1, :b => 2, :c => 3 }
  delta [ 1, 2, 3 ]

end
```

### Reading a configuration

Retrieve settings...

```ruby
conf.alpha 42
conf.bravo "foobar"
conf.charlie { :a => 1, :b => 2, :c => 3 }
conf.delta [ 1, 2, 3 ]
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

Licensed under GPL Version 3 license
See LICENSE file

