# Iqeo::Conf

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'iqeo-conf'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install iqeo-conf

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

# example conf DSL

conf = Conf.new 'name_0' do

  # values

  var_str "String"
  var_int 123
  var_arr [ 1, 2, 3]
  var_hsh { :a => 1, :b => 2, :c => 3 }

  # sub configs in different ways

  var_conf_1 Conf.new 'name_1' do
    ...
  end

  var_conf_2 Conf.new do
    ...
  end

  var_conf_3 'name_3' do
    ...
  end

  var_conf_4 do
    ...
  end

  level 1

  var_conf_5 'name_5' do

    level 2

    var_conf_6 'name_6' do

      level 3

      var_conf_7 'name_7' do

        # Conf.inherit ?
        level 4

      end

    end

  end

  other Conf.load 'file...' # etc...

end


# include config files

## return either a single Conf hierarchy or an array of Conf depending upon the file contents

Conf.path = [ '*' , '**/*.rb', "config/config.rb" ]
Conf.load                => Conf...  # no parameter defaults to Conf::path value
Conf.load filename       => Conf...
Conf.load glob           => Conf... / [Conf..., ...]
Conf.load [filename,...] => Conf... / [Conf..., ...]
Conf.load [glob,...]     => Conf... / [Conf..., ...]

# usage

## retrieve values

conf.name      => 'name_0'
conf.var_str   => "String"
conf.var_int   => 123
conf.var_arr   => [1,2,3]
conf.var_hsh   => { :a => 1, :b => 2, :c => 3 }

## retrieve sub-configurations

conf.var_conf_1 => Conf...
conf.var_conf_1.name => 'name_1'

## nested configurations

conf.level                                  => 1
conf.var_conf_5.level                       => 2
conf.var_conf_5.var_conf_6.level            => 3
conf.var_conf_5.var_conf_6.var_conf_7.level => 4

## set or create values

conf.existing_item "change to this"
conf.new_item "new value"

## indifferent keys

conf.name      =>  'name_0'
conf[:name]    =>  'name_0'
conf['name']   =>  'name_0'

## enumeration

conf.values                => # array of values like a hash

conf.keys                  => # array of string keys
conf.keys_as_strings       => # array of string keys
conf.keys_as_symbols       => # array of symbol keys

conf.to_hash               => # hash of string key + value pairs
conf.to_hash_with_strings  => # hash of string key + value pairs
conf.to_hash_with_symbols  => # hash of symbol key + value pairs

conf.each do |key,value|           # key will be string
  puts key + " = " + value
end

conf.each_with_strings |key,value| # key will be string
...

conf.each_with_symbols |key,value| # key will be hash
...

# how about hashes with keys other than strings and symbols ?
# conf.to_hash { |k| k.method ... }

