
require_relative "configuration/version"

# todo: access to items by hash
# todo: indifferent hash access
# todo: nested configurations
# todo: inherited settings for nested configurations
# todo: load configurations from string & file
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
      name = name.to_s.chomp('=').to_sym
      return @items[name] if values.empty?
      return @items[name] = values if values.size > 1
      return @items[name] = values.first
    end

  end

end

