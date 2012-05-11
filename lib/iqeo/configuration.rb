
require_relative "configuration/version"
require_relative "configuration/hash_with_indifferent_access"

# todo: use an existing configuration for defaults
# todo: blank slate for DSL - optional ?
# todo: option to get hash directly to prevent polluting namespace with delegated hash methods
# todo: consider issues around deferred interpolation / procs / lambdas etc...
# todo: load other formats from string & file - YAML, CSV, ...anything Enumerable should be easy enough.

# todo: rdoc readme and documentation

=begin
  Title
    blurb...

  Installation
    gem...

  Usage

    Create configuration
      modes of usage...

      Explicit
        example...

        conf = Configuration.new
        conf.alpha 1
        conf.bravo 2.0
        conf.charlie :three
        conf.delta "four"
        conf.echo Configuration.new
        conf.echo.foxtrot true

      Block DSL
        example... yield

        conf = Configuration.new do |c|
          c.alpha 1
          c.bravo 2.0
          c.charlie :three
          c.delta "four"
          c.echo do |e|
            e.foxtrot true
          end
        end

      Eval DSL
        example... instance_eval

        conf = Configuration.new do
          alpha 1
          bravo 2.0
          charlie :three
          delta "four"
          echo do
            foxtrot true
          end
        end

    Read configuration
      examples...

        method access

          conf.alpha        => 1
          conf.bravo        => 2.0
          conf.charlie      => :three
          conf.delta        => "four"
          conf.echo         => Configuration...
          conf.echo.foxtrot => true

        string access

          conf['alpha']             => 1
          conf['bravo']             => 2.0
          conf['charlie']           => :three
          conf['delta']             => "four"
          conf['echo']              => Configuration...
          conf['echo']['foxtrot']   => true

        symbol access

          conf[:alpha]           => 1
          conf[:bravo]           => 2.0
          conf[:charlie]         => :three
          conf[:delta]           => "four"
          conf[:echo]            => Configuration...
          conf[:echo][:foxtrot]  => true

        enumerable hash

          conf.collect { |key,value| value }  => [ 1, 2.0, :three, 'four' ]  ... + nested configuration ?

        inheritance

  Features
    Per mode
      setting value
      setting/local = value
      existing setting + override
      nesting
      inherited setting + override
      load from string + file, merge + nest
      [] and []= methods + self
      + merge
      + defaults
      + blank slate

=end


module Iqeo

  class Configuration

    def self.version
      VERSION
    end

    def self.read string
      conf = self.new
      conf.instance_eval string
      conf
    end

    def self.load file
      return self.read file.respond_to?(:read) ? file.read : File.read(file)
    end

    def self.new_defer_block_for_parent parent, &block
      conf = Configuration.new
      conf._parent = parent
      if block_given? && block.arity == 1
        block.call(conf)                                              # this is 'yield self' from the outside
      else
        raise "WTF! expected a block with a single parameter"
      end
      conf
    end

    def initialize &block
      @items = HashWithIndifferentAccess.new
      @_parent = nil
      if block_given?
        if block.arity == 1                                           # cannot set parent for yield blocks here as self is wrong !?
          yield self
        else
          if block.binding.eval('self').kind_of?( Configuration )     # for eval block if nested configuration
            @_parent = block.binding.eval('self')                     # set parent to make inherited values available
          end                                                         # during block execution
          instance_eval &block
        end
      end
    end

    def method_missing name, *values, &block
      return @items.send( name, *values, &block ) if @items.respond_to? name     # @items methods are highest priority

      name = name.to_s.chomp('=')

      if block_given?                                                 # block is a nested configuration
        if block.arity == 1                                           # yield DSL needs deferred block to set parent without binding
          return _set name, Configuration.new_defer_block_for_parent( self, &block )
        else
          return _set name, Configuration.new( &block )               # eval DSL can set parent from block binding in initialize
        end
      end

      return _get name if values.empty?                               # just get item
      return _set name, values if values.size > 1                     # set item to multiple values
      return _set name, values.first                                  # set item to single value
    end

    attr_accessor :_parent

    def _set key, value
      # fix: extend parenting for enumerable with configurations at arbitrary depth
      case
      when value.kind_of?( Configuration ) then value._parent = self
      when value.kind_of?( Enumerable )    then value.each { |v| v._parent = self if v.kind_of? Configuration }
      end
      @items[key] = value
    end
    alias []= _set

    def _get key
      return @items[key] unless @items[key].nil?
      return @items[key] if  _parent.nil?
      _parent._get key
    end
    alias [] _get

    def _read string
      instance_eval string
    end

    def _load file
      _read file.respond_to?(:read) ? file.read : File.read(file)
    end

  end

end

