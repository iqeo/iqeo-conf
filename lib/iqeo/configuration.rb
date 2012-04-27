
require_relative "configuration/version"
require_relative "configuration/hash_with_indifferent_access"

# todo: configuration file load path - array of Dir.glob like file specs ?
# todo: use an existing configuration for defaults
# todo: clean DSL syntax for creating a configuration - just a block ?
# todo: load configurations from a string or file after creation / in DSL block
# todo: option to get hash directly to prevent polluting namespace with delegated hash methods
# todo: blank slate for DSL - optional ?
# todo: global configuration - watch for collisions ?
# todo: deferred interpolation / procs / lambdas etc...
# todo: load other formats from string & file - YAML, XML?

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

    def self.file file
      return self.read file.respond_to?(:read) ? file.read : File.read(file)
    end

    def initialize &block
      @items = HashWithIndifferentAccess.new
      @_parent = nil
      if block_given?
       if block.arity == 1
         yield self
       else
         instance_eval &block
       end
      end
    end

    def method_missing name, *values
      return @items.send name, *values if @items.respond_to? name
      # this is unreachable since these methods are delegated to @items hash
      # but keep it around for when we make selective delegation an option
      #case name
      #when :[]= then return _set values.shift, values.size > 1 ? values : values.first
      #when :[]  then return _get values.shift
      #end
      name = name.to_s.chomp('=')        # todo: write a test case for a non-string object as key being converted by .to_s
      return _get name if values.empty?
      return _set name, values if values.size > 1
      return _set name, values.first
    end

    attr_accessor :_parent  # todo: should attr_writer be protected ?

    def _set key, value
      # todo: extend parenting for enumerable with configurations at arbitrary depth ?
      case
      when value.kind_of?( Configuration ) then value._parent = self
      when value.kind_of?( Enumerable )    then value.each { |v| v._parent = self if v.kind_of? Configuration }
      end
      @items[key] = value
    end

    def _get key
      return @items[key] unless @items[key].nil?
      return @items[key] if  _parent.nil?
      return _parent._get key
    end

  end

end

