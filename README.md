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

### Use a Configuration object directly

```ruby
conf = Iqeo::Configuration.new
```

Add some settings

```ruby
conf.one 1
conf.two 2
```

Retrieve settings

```ruby
conf.one   => 1
conf.two   => 2
```

### Configuration DSL - builder style

```ruby
conf = Iqeo::Configuration do |c|

  c.three 3
  c.four 4

end
```

Retrieve settings

```ruby
conf.three   => 3
conf.four    => 4
```

### Configuration DSL - freestyle

```ruby
conf = Iqeo::Configuration do

  five 5
  six 6

end
```

Retrieve settings

```ruby
conf.five   => 5
conf.six    => 6
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

