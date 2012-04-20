
require_relative "configuration/version"

module Iqeo

  class Configuration

    # todo: tests - init without block, with block & param, with plain block
    # todo: instance_eval vs. yield (arity == 0) ?

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

    # todo: tests - with value, without value, multiple values ?, optional '=' with value ?
    # todo: why does '=' break for instance eval ? - is it actually setting a local variable ???

    def method_missing name, *value
      name = name.to_s.chomp('=').to_sym
      return @items[name] if value.empty?
      @items[name] = value.first
    end

  end

end

