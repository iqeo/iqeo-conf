
require_relative "configuration/version"

# todo: load configurations from string & file
# todo: configuration file load path
# todo: iterate over items hash - access to hash / mixin enumerable / delegation to hash ?
# todo: indifferent hash access
# todo: use an existing configuration for defaults
# todo: global configuration - watch for collisions ?
# todo: deferred interpolation / procs / lambdas etc...
# todo: blank slate for DSL - optional ?
# todo: load other formats from string & file - YAML, XML?

module Iqeo

  class Configuration

    def self.version
      VERSION
    end

    def initialize &block
      @items = {}
      @__parent__ = nil
      if block_given?
       if block.arity == 1
         yield self
       else
         instance_eval &block
       end
      end
    end

    def method_missing name, *values
      case name
      when :[]= then return __set__ values.shift, values.size > 1 ? values : values.first
      when :[]  then return __get__ values.shift
      end
      name = name.to_s.chomp('=').to_sym
      return __get__ name if values.empty?
      return __set__ name, values if values.size > 1
      return __set__ name, values.first
    end

    attr_accessor :__parent__  # todo: should attr_writer be protected ?

    def __set__ key, value
      # todo: extend parenting for values with configurations at arbitrary depth ?
      case
      when value.kind_of?( Configuration ) then value.__parent__ = self
      when value.kind_of?( Enumerable )    then value.each { |v| v.__parent__ = self if v.kind_of? Configuration }
      end
      @items[key] = value
    end

    def __get__ key
      return @items[key] unless @items[key].nil?
      return @items[key] if  __parent__.nil?
      return __parent__.__get__ key
    end

 end

end

