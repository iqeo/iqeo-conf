
require_relative "configuration/version"

# todo: inherited settings for nested configurations - POLS ?
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
      when :[]= then return @items[values.shift] = values.size > 1 ? values : values.first
      when :[]  then return @items[values.shift]
      else
        name = name.to_s.chomp('=').to_sym
        return @items[name] if values.empty?
        return @items[name] = values if values.size > 1
        return @items[name] = values.first
      end
    end
 end

end

